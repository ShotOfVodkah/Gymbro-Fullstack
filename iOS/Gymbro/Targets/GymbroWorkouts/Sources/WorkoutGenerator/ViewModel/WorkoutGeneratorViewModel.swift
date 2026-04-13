import Foundation
import Combine

import GymbroNavigation
import GymbroTypes
import GymbroNetwork

@MainActor
final class WorkoutGeneratorViewModel: ObservableObject {

    init(
        modelModifier: WorkoutsModelModifier,
        router: any Router,
        service: any WorkoutGeneratorService,
        analytics: any AnalyticsService
    ) {
        self.service = service
        self.router = router
        self.modelModifier = modelModifier
        self.analytics = analytics
        analytics.track(.screenViewed(screen: .workoutGenerator))
    }

    // MARK: - Actions

    func exit() {
        router.pop()
    }
    
    func dismiss() {
        generated = nil
        screenState = .loaded
    }

    func toggleInjury(_ injury: Injury) {
        if selectedInjuries.contains(injury) {
            selectedInjuries.remove(injury)
        } else {
            selectedInjuries.insert(injury)
        }
    }

    func generateWorkout() async {
        guard !prompt.isEmpty else {
            showAlert = true
            return
        }
        screenState = .loading
        generated = nil
        do {
            let (workout, state) = try await service.generate(
                prompt: prompt,
                injuries: Array(selectedInjuries)
            )
            analytics.track(.workoutGenerated(promptLength: prompt.count, exerciseCount: workout.exercises.count))
            self.screenState = state
            self.generated = workout
        } catch {
            print(error)
            screenState = .error
        }
    }
    
    func saveWorkout() {
        guard let generated else { return }
        Task {
            await service.saveWorkout(generated)
            modelModifier.events.send(.workoutAdded(id: generated.id))
            self.generated = nil
            router.popToRoot()
        }
    }

    // MARK: - Published state

    @Published var prompt: String = ""
    @Published var selectedInjuries: Set<Injury> = []
    @Published var screenState: ScreenState = .loaded
    @Published var generated: Workout?
    @Published var showAlert: Bool = false

    private let analytics: any AnalyticsService
    private let router: any Router
    private let service: any WorkoutGeneratorService
    private let modelModifier: WorkoutsModelModifier
}
