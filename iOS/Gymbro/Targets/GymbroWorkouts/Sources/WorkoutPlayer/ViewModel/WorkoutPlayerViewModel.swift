import Foundation

import GymbroNavigation
import GymbroTypes

@MainActor
final class WorkoutPlayerViewModel: ObservableObject {

    init(
        id: String,
        router: any Router
    ) {
        self.workoutId = id
        self.router = router

        let workout = WorkoutPlayerMockData.workout(for: id)
        self.workoutName = workout.name
        self.workoutType = workout.type
        self.exercises = workout.exercises.map {ExerciseItem(from: $0)}
    }

    func backButtonTapped() {
        showAlert = true
    }
    
    func exit() {
        router.pop()
    }

    @Published var currentExerciseIndex: Int = 0
    @Published var showAlert = false

    var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(currentExerciseIndex + 1) / Double(exercises.count)
    }
    var positionLabel: String {
        guard !exercises.isEmpty else { return "0 / 0" }
        return "\(currentExerciseIndex + 1) / \(exercises.count)"
    }
    var currentExercise: ExerciseItem? {
        guard exercises.indices.contains(currentExerciseIndex) else { return nil }
        return exercises[currentExerciseIndex]
    }

    var nextExercise: ExerciseItem? {
        guard exercises.indices.contains(currentExerciseIndex + 1) else { return nil }
        return exercises[currentExerciseIndex]
    }

    let workoutId: String
    let workoutName: String
    let exercises: [ExerciseItem]
    let workoutType: WorkoutType
    private let router: any Router
}
