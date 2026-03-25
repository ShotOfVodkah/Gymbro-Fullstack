import Foundation

import GymbroTypes

protocol WorkoutPlayerService {
    func fetchWorkout(id: String) async -> (WorkoutPlayerViewState, ScreenState)
}

final class WorkoutPlayerServiceImpl: WorkoutPlayerService {

    init() {}

    func fetchWorkout(id: String) async -> (WorkoutPlayerViewState, ScreenState) {
        let workout = WorkoutPlayerMockData.workout(for: id)
        return (WorkoutPlayerViewState(
            workoutName: workout.name,
            workoutType: workout.type,
            exercises: workout.exercises.map { ExerciseItem(from: $0) }
        ), .loaded)
    }
}
