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
        type: WorkoutInfoType,
        service: any WorkoutInfoService,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        analytics: any AnalyticsService
    ) {
        self.service = service
        self.router = router
        self.modelModifier = modelModifier
        self.analytics = analytics

        let handler = WorkoutInfoDivUrlHandler { [weak self] link in
            Task { [weak self] in
                await self?.handle(link: link)
            }
        }
        self.divkitComponents = DivKitComponents(urlHandler: handler)

        modelModifier.events
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .workoutEdited(let id): fetchData(with: id, type: .workout)
                case .statusChanged(let status): handleStatusChange(status: status)
                default: break
                }
            }
            .store(in: &cancellables)

        analytics.track(.screenViewed(screen: .workoutInfo))
        fetchData(with: id, type: type)
    }

    // MARK: - Actions

    func fetchData(with id: String, type: WorkoutInfoType) {
        screenState = .loading
        Task {
            do {
                let (data, state) = try await service.fetchScreen(id: id, type: type)
                source = DivViewSource(kind: .data(data), cardId: "WorkoutInfoCard")
                modelModifier.events.send(.statusChanged(status: state == .loaded ? .online : .offline))
                screenState = state
            } catch {
                analytics.track(.errorOccurred(screen: AnalyticsScreen.workoutInfo.rawValue, message: error.localizedDescription))
                screenState = .error
            }
        }
    }

    func backButtonTapped() {
        router.pop()
    }

    func deleteCurrentWorkout() {
        guard let id else { return }
        Task {
            await service.deleteWorkout(id: id)
            modelModifier.events.send(.workoutDeleted(id: id))
            router.pop()
        }
    }

    // MARK: - Published state

    @Published var screenState: ScreenState = .loading
    @Published var showDeleteAlert: Bool = false
    @Published var showAddAlert: Bool = false
    @Published var source: DivViewSource? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())

    // MARK: - Private

    private var id: String?
    private var cancellables = Set<AnyCancellable>()
    private let service: any WorkoutInfoService
    private let modelModifier: WorkoutsModelModifier
    private let router: any Router
    private let analytics: any AnalyticsService

    private func handle(link: WorkoutInfoNavigationLink) async {
        switch link {
        case .openPlayer(let id):
            router.navigate(to: .workoutPlayer(id: id))
        case .edit(let id):
            router.navigate(to: .workoutBuilderForType(type: nil, workoutId: id))
        case .delete(let id):
            self.id = id
            showDeleteAlert = true
        case .addToMy(let id):
            do {
                try await service.addWorkout(id: id)
            } catch {
                showAddAlert = true
            }
            router.pop()
            modelModifier.events.send(.forceReload)
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
