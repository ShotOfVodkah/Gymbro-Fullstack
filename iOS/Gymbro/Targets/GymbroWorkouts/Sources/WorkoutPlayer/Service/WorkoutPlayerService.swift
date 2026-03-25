import Foundation

import GymbroTypes

protocol WorkoutPlayerService {
    func fetchWorkout(id: String) async throws -> (WorkoutPlayerViewState, ScreenState)
}

final class WorkoutPlayerServiceImpl: WorkoutPlayerService {

    init() {}

    func fetchWorkout(id: String) async throws -> (WorkoutPlayerViewState, ScreenState) {
        let workout = workoutsMock.first(where: {$0.id == id})
        guard let workout else {
            throw WorkoutsServiceError.noData
        }
        return (WorkoutPlayerViewState(
            workoutName: workout.name,
            workoutType: workout.type,
            exercises: workout.exercises.map { ExerciseItem(from: $0) }
        ), .loaded)
    }
}
