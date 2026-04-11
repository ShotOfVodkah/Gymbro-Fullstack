import Foundation
import DivKit
import Combine

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class WorkoutBuilderViewModel: ObservableObject {

    init(
        service: any WorkoutBuilderService,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        analytics: any AnalyticsService
    ) {
        self.service = service
        self.router = router
        self.modelModifier = modelModifier
        self.analytics = analytics

        let handler = WorkoutBuilderTitleDivUrlHandler { [weak self] link in
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

        analytics.track(.screenViewed(screen: .workoutBuilder))
        fetchData()
    }

    // MARK: - Actions

    func fetchData() {
        Task {
            do {
                let (data, state) = try await service.fetchScreen()
                source = DivViewSource(kind: .data(data), cardId: "WorkoutBuilder")
                modelModifier.events.send(.statusChanged(status: state == .loaded ? .online : .offline))
                screenState = state
            } catch {
                analytics.track(.errorOccurred(screen: AnalyticsScreen.workoutBuilder.rawValue, message: error.localizedDescription))
                screenState = .error
            }
        }
    }

    func presentSheet(id: String) {
        Task {
            guard let data = try? await service.fetchSheet(id: id) else { return }
            sheetModel = PremadeWorkoutSheet.Model(
                components: divkitComponents,
                source: DivViewSource(kind: .data(data), cardId: "WorkoutBuilderSheet")
            )
        }
    }

    func backButtonTapped() {
        router.pop()
    }

    // MARK: - Published state

    @Published var screenState: ScreenState = .loading
    @Published var source: DivViewSource? = nil
    @Published var sheetModel: PremadeWorkoutSheet.Model? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private let service: any WorkoutBuilderService
    private let modelModifier: WorkoutsModelModifier
    private let router: any Router
    private let analytics: any AnalyticsService

    private func handle(link: WorkoutBuilderTitleNavigationLink) {
        switch link {
        case .openAI:
            print("stub")
        case .openBuilder(let type):
            router.navigate(to: .workoutBuilderForType(type: type, workoutId: nil))
        case .openPremade(let id):
            presentSheet(id: id)
        case .savePremade(let id):
            Task {
                await service.addPremadeWorkout(id: id)
            }
            modelModifier.events.send(.premadeWorkoutAdded(id: id))
            sheetModel = nil
            backButtonTapped()
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
