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
        service: any WorkoutGeneratorService
    ) {
        self.service = service
        self.router = router
        self.modelModifier = modelModifier
    }

    // MARK: - Actions
    
    func exit() {
        router.pop()
    }
    
    func generateWorkout() async {
        do {
            let (workout, screenState) = try await service.generate(
                prompt: "Нужна кардио тренировка на 20 минут, начинающий уровень",
                injuries: []
            )
            self.screenState = screenState
            self.generated = workout
        } catch {
            screenState = .error
        }
    }
    
    // MARK: - Published state

    @Published var screenState: ScreenState = .loaded
    @Published var generated: Workout?

    private let router: any Router
    private let service: any WorkoutGeneratorService
    private let modelModifier: WorkoutsModelModifier
}
