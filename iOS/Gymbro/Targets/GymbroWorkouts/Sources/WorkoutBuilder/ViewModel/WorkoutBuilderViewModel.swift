import Foundation
import DivKit
import Combine

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class WorkoutBuilderViewModel: ObservableObject {

    init(
        networkClient: WorkoutsNetworkClient,
        router: any Router,
        divLocalRepository: DivCacheRepository,
        actionsRepository: OfflineActionsRepository,
        modelModifier: WorkoutsModelModifier,
        localMapper: WorkoutsLocalMapper
    ) {
        self.router = router
        self.networkClient = networkClient
        self.divLocalRepository = divLocalRepository
        self.actionsRepository = actionsRepository
        self.modelModifier = modelModifier
        self.localMapper = localMapper
        
        let handler = WorkoutBuilderTitleDivUrlHandler{ [weak self] link in
            self?.handle(link: link)
        }
        self.divkitComponents = DivKitComponents(urlHandler: handler)
        
        modelModifier.events
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .statusChanged(let status): handleStatusChange(status: status)
                default: break
                }
            }
            .store(in: &cancellables)
        
        fetchData()
    }
    
    private func handle(link: WorkoutBuilderTitleNavigationLink) {
           switch link {
           case .openAI:
               print("stub")
           case .openBuilder(let type):
               router.navigate(to: .workoutBuilderForType(type: type, workoutId: nil))
           case .openPremade(let id):
               presentSheet(id: id)
           case .savePremade(let id):
               actionsRepository.enqueueSmart(.premadeAdded(id: id))
               modelModifier.events.send(.premadeWorkoutAdded(id: id))
               sheetModel = nil
               backButtonTapped()
           }
       }


    func fetchData() {
        Task {
            do {
                let data = try await networkClient.fetchWorkoutBuilderTitleJson()
                divLocalRepository.save(key: "workoutBuilderTitle", data: data)
                source = DivViewSource(kind: .data(data), cardId: "WorkoutBuilder")
                modelModifier.events.send(.statusChanged(status: .online))
                screenState = .loaded
            } catch {
                guard let data = divLocalRepository.load(key: "workoutBuilderTitle") else {
                    screenState = .error
                    return
                }
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
                modelModifier.events.send(.statusChanged(status: .offline))
                screenState = .offline
            }
        }
    }
    
    func presentSheet(id: String) {
        Task {
            do {
                let data = try await networkClient.fetchWorkoutBuilderSheetJson(with: id)
                sheetModel = PremadeWorkoutSheet.Model(
                    components: divkitComponents,
                    source: DivViewSource(kind: .data(data), cardId: "WorkoutBuilderSheet")
                )
            } catch {
                guard let data = localMapper.renderWorkoutBuilder(id: id) else {
                    return
                }
                sheetModel = PremadeWorkoutSheet.Model(
                    components: divkitComponents,
                    source: DivViewSource(kind: .data(data), cardId: "WorkoutBuilderSheet")
                )
            }
        }
    }
    
    func backButtonTapped() {
        router.pop()
    }
    
    private func handleStatusChange(status: OfflineStatus) {
        switch screenState {
        case .loaded, .offline:
            switch status {
            case .offline: screenState = .offline
            case .online: screenState = .loaded
            }
        case .error, .loading: break
        }
    }

    @Published var screenState: ScreenState = .loading
    @Published var source: DivViewSource? = nil
    @Published var sheetModel: PremadeWorkoutSheet.Model? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())

    private var cancellables = Set<AnyCancellable>()
    private let modelModifier: WorkoutsModelModifier
    private let localMapper: WorkoutsLocalMapper
    private let divLocalRepository: DivCacheRepository
    private let actionsRepository: OfflineActionsRepository
    private let router: any Router
    private let networkClient: WorkoutsNetworkClient
}
