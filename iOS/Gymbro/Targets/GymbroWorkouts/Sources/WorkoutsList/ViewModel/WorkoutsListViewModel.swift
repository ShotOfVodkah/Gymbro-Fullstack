import Foundation
import DivKit
import Combine

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class WorkoutsListViewModel: ObservableObject {

    struct StreakSheetModel: Identifiable {
        var id: Int

        let current: Int
        let goal: Int
        let daysLeft: Int
        let value: Int

        init(current: Int, goal: Int, daysLeft: Int, value: Int) {
            self.id = value
            self.current = current
            self.goal = goal
            self.daysLeft = daysLeft
            self.value = value
        }
    }

    init(
        service: any WorkoutsListService,
        router: any Router,
        modelModifier: WorkoutsModelModifier
    ) {
        self.service = service
        self.router = router
        self.modelModifier = modelModifier

        let handler = WorkoutsDivUrlHandler { [weak self] link in
            self?.handle(link: link)
        }
        self.divkitComponents = DivKitComponents(urlHandler: handler)

        modelModifier.events
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .statusChanged(let status): handleStatusChange(status: status)
                case .workoutDeleted(let id): handleDelete(id: id)
                case .premadeWorkoutAdded(let id): handleAdd(id: id, fromPremade: true)
                case .workoutAdded(let id): handleAdd(id: id, fromPremade: false)
                case .workoutEdited: break
                }
            }
            .store(in: &cancellables)

        fetchData()
    }

    // MARK: - Actions

    func fetchData() {
        Task {
            do {
                let (data, state) = try await service.fetchScreen()
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
                modelModifier.events.send(.statusChanged(status: state == .loaded ? .online : .offline))
                screenState = state
            } catch {
                screenState = .error
            }
        }
    }

    func handleAdd(id: String, fromPremade: Bool) {
        guard let newData = service.addWorkoutCard(id: id, fromPremade: fromPremade) else { return }
        source = DivViewSource(kind: .data(newData), cardId: DivCardID(rawValue: "WorkoutsCard_\(UUID().uuidString)"))
        sourceDebugId += 1
    }

    func handleDelete(id: String) {
        guard let newData = service.removeWorkoutCard(id: id) else { return }
        source = DivViewSource(kind: .data(newData), cardId: DivCardID(rawValue: "WorkoutsCard_\(UUID().uuidString)"))
        sourceDebugId += 1
    }

    // MARK: - Published state

    @Published var sourceDebugId: Int = 0
    @Published var hostingView: DivHostingView? = nil
    @Published var screenState: ScreenState = .loading
    @Published var source: DivViewSource? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())
    @Published var streakModel: StreakSheetModel? = nil
    @Published var showOfflineAlert: Bool = false

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private let service: any WorkoutsListService
    private let modelModifier: WorkoutsModelModifier
    private let router: any Router

    private func handle(link: WorkoutsNavigationLink) {
        switch link {
        case .openWorkout(let id):
            router.navigate(to: .workoutInfo(id: id))
        case .openBuilder:
            router.navigate(to: .workoutBuilder)
        case .openStreak(let current, let goal, let daysLeft, let value):
            streakModel = StreakSheetModel(
                current: current,
                goal: goal,
                daysLeft: daysLeft,
                value: value
            )
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
