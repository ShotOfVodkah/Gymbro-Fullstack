import Foundation

import DivKit

import GymbroNavigation
import GymbroNetwork

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
        localRepository: DivCacheRepository,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        localMapper: WorkoutsLocalMapper
    ) {
        self.networkClient = networkClient
        self.localRepository = localRepository
        self.router = router
        self.modelModifier = modelModifier
        self.localMapper = localMapper
        
        let handler = WorkoutInfoDivUrlHandler{ [weak self] link in
            self?.handle(link: link)
        }
        self.divkitComponents = DivKitComponents(urlHandler: handler)
        fetchData(with: id)
    }
    
    private func handle(link: WorkoutInfoNavigationLink) {
        switch link {
        case .openPlayer(let id):
            print("player")
        case .edit(let id):
            if screenState == .offline {
                showOfflineAlert = true
            } else {
                print("edit")
            }
        case .delete(let id):
            if screenState == .offline {
                showOfflineAlert = true
            } else {
                showAlert = true
            }
        }
    }


    func fetchData(with id: String) {
        screenState = .loading
        Task {
            do {
                let data = try await networkClient.fetchWorkoutInfoDivJson(with: id)
                source = DivViewSource(kind: .data(data), cardId: "WorkoutInfoCard")
                screenState = .loaded
            } catch {
                guard let data = localMapper.renderWorkoutInfo(id: id) else {
                    screenState = .error
                    return
                }
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
                screenState = .offline
            }
        }
    }
    
    func backButtonTapped() {
        router.pop()
    }
    
    func deleteCurrentWorkout() {
        modelModifier.events.send(.workoutDeleted)
        router.pop()
    }

    @Published var screenState: ScreenState = .loading
    @Published var showAlert: Bool = false
    @Published var showOfflineAlert: Bool = false
    @Published var source: DivViewSource? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())

    private var localMapper: WorkoutsLocalMapper
    private let modelModifier: WorkoutsModelModifier
    private let localRepository: DivCacheRepository
    private let router: any Router
    private let networkClient: WorkoutsNetworkClient
}
