import Foundation
import DivKit
import Combine

import GymbroNavigation
import GymbroNetwork

@MainActor
final class WorkoutBuilderViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case offline
        case error
    }

    init(
        networkClient: WorkoutsNetworkClient,
        router: any Router,
        localRepository: DivCacheRepository,
        modelModifier: WorkoutsModelModifier,
        localMapper: WorkoutsLocalMapper
    ) {
        self.router = router
        self.networkClient = networkClient
        self.localRepository = localRepository
        self.modelModifier = modelModifier
        self.localMapper = localMapper
        
        let handler = WorkoutBuilderTitleDivUrlHandler{ [weak self] link in
            self?.handle(link: link)
        }
        self.divkitComponents = DivKitComponents(urlHandler: handler)
        
        fetchData()
    }
    
    private func handle(link: WorkoutBuilderTitleNavigationLink) {
           switch link {
           case .openAI:
               print("stub")
           case .openBuilder:
               print("stub")
           case .openPremade(let id):
               presentSheet(id: id)
           case .savePremade(let id):
               modelModifier.events.send(.premadeWorkoutAdded(id: id))
               sheetModel = nil
               backButtonTapped()
           }
       }


    func fetchData() {
        Task {
            do {
                let data = try await networkClient.fetchWorkoutBuilderTitleJson()
                localRepository.save(key: "workoutBuilderTitle", data: data)
                source = DivViewSource(kind: .data(data), cardId: "WorkoutBuilder")
                screenState = .loaded
            } catch {
                guard let data = localRepository.load(key: "workoutBuilderTitle") else {
                    screenState = .error
                    return
                }
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
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

    @Published var screenState: ScreenState = .loading
    @Published var source: DivViewSource? = nil
    @Published var sheetModel: PremadeWorkoutSheet.Model? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())

    private let modelModifier: WorkoutsModelModifier
    private let localMapper: WorkoutsLocalMapper
    private let localRepository: DivCacheRepository
    private let router: any Router
    private let networkClient: WorkoutsNetworkClient
}
