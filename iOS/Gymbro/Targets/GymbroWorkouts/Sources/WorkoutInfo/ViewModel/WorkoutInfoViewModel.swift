import Foundation
import Combine

import DivKit

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class WorkoutInfoViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case offline
        case error
    }

    init(
        id: String,
        networkClient: WorkoutsNetworkClient,
        divLocalRepository: DivCacheRepository,
        actionsRepository: OfflineActionsRepository,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        localMapper: WorkoutsLocalMapper
    ) {
        self.networkClient = networkClient
        
        self.localRepository = divLocalRepository
        self.actionsRepository = actionsRepository
        
        self.router = router
        self.modelModifier = modelModifier
        self.localMapper = localMapper
        
        let handler = WorkoutInfoDivUrlHandler{ [weak self] link in
            self?.handle(link: link)
        }
        
        modelModifier.events
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .workoutEdited(let id): fetchData(with: id)
                case .statusChanged(let status): handleStatusChange(status: status)
                default: break
                }
            }
            .store(in: &cancellables)
        
        self.divkitComponents = DivKitComponents(urlHandler: handler)
        fetchData(with: id)
    }
    
    private func handle(link: WorkoutInfoNavigationLink) {
        switch link {
        case .openPlayer(let id):
            print("player")
        case .edit(let id):
            router.navigate(to: .workoutBuilderForType(type: nil, workoutId: id))
        case .delete(let id):
            self.id = id
            showAlert = true
        }
    }


    func fetchData(with id: String) {
        screenState = .loading
        Task {
            do {
                let data = try await networkClient.fetchWorkoutInfoDivJson(with: id)
                source = DivViewSource(kind: .data(data), cardId: "WorkoutInfoCard")
                modelModifier.events.send(.statusChanged(status: .online))
                screenState = .loaded
            } catch {
                guard let data = localMapper.renderWorkoutInfo(id: id) else {
                    screenState = .error
                    return
                }
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
                modelModifier.events.send(.statusChanged(status: .offline))
                screenState = .offline
            }
        }
    }
    
    func backButtonTapped() {
        router.pop()
    }
    
    func deleteCurrentWorkout() {
        guard let id else { return }
        actionsRepository.enqueueSmart(.deletedWorkout(id: id))
        modelModifier.events.send(.workoutDeleted(id: id))
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
    @Published var showAlert: Bool = false
    @Published var source: DivViewSource? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())

    private var id: String?
    private var cancellables = Set<AnyCancellable>()
    private var localMapper: WorkoutsLocalMapper
    private let modelModifier: WorkoutsModelModifier
    private let localRepository: DivCacheRepository
    private let actionsRepository: OfflineActionsRepository
    private let router: any Router
    private let networkClient: WorkoutsNetworkClient
}
