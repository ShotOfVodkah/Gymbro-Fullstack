import Foundation
import Combine

import DivKit

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class WorkoutInfoViewModel: ObservableObject {

    init(
        id: String,
        service: any WorkoutInfoService,
        router: any Router,
        modelModifier: WorkoutsModelModifier
    ) {
        self.service = service
        self.router = router
        self.modelModifier = modelModifier

        let handler = WorkoutInfoDivUrlHandler { [weak self] link in
            self?.handle(link: link)
        }
        self.divkitComponents = DivKitComponents(urlHandler: handler)

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

        fetchData(with: id)
    }

    // MARK: - Actions

    func fetchData(with id: String) {
        screenState = .loading
        Task {
            do {
                let (data, state) = try await service.fetchScreen(id: id)
                source = DivViewSource(kind: .data(data), cardId: "WorkoutInfoCard")
                modelModifier.events.send(.statusChanged(status: state == .loaded ? .online : .offline))
                screenState = state
            } catch {
                screenState = .error
            }
        }
    }

    func backButtonTapped() {
        router.pop()
    }

    func deleteCurrentWorkout() {
        guard let id else { return }
        service.deleteWorkout(id: id)
        modelModifier.events.send(.workoutDeleted(id: id))
        router.pop()
    }

    // MARK: - Published state

    @Published var screenState: ScreenState = .loading
    @Published var showAlert: Bool = false
    @Published var source: DivViewSource? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())

    // MARK: - Private

    private var id: String?
    private var cancellables = Set<AnyCancellable>()
    private let service: any WorkoutInfoService
    private let modelModifier: WorkoutsModelModifier
    private let router: any Router

    private func handle(link: WorkoutInfoNavigationLink) {
        switch link {
        case .openPlayer(let id):
            router.navigate(to: .workoutPlayer(id: id))
        case .edit(let id):
            router.navigate(to: .workoutBuilderForType(type: nil, workoutId: id))
        case .delete(let id):
            self.id = id
            showAlert = true
        }
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
}
