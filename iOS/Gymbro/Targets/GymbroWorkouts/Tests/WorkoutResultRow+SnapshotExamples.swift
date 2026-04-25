import GymbroTypes
import SwiftUI

@testable import GymbroWorkouts

enum WorkoutResultRowSnapshotExamples {
    static let snapshotSize = CGSize(width: 300, height: 100)

    static let snapshotExamples: [ResultRowSnapshotCase] = [
        ResultRowSnapshotCase(
            name: "yoga_exercise",
            makeView: {
                WorkoutResultRow(item: ExerciseItem(from: yogaEcxercise))
            }
        ),
        ResultRowSnapshotCase(
            name: "cardio_exercise",
            makeView: {
                WorkoutResultRow(item: ExerciseItem(from: cardioEcxercise))
            }
        ),
        ResultRowSnapshotCase(
            name: "strength_exercise",
            makeView: {
                WorkoutResultRow(item: ExerciseItem(from: strengthEcxercise))
            }
        )
    ]

    
    static let shortName: String = "Short Name"
    static let longName: String = "Long Name"
    
    static let yogaEcxercise: any Exercise = YogaExercise(
        id: "",
        name: "Yoga Exercise",
        muscleGroup: .chest,
        holdSeconds: 10,
        breathCount: 10
    )
    
    static let cardioEcxercise: any Exercise = CardioExercise(
        id: "",
        name: "Cardio Exercise",
        muscleGroup: .chest,
        durationMinutes: 60,
        pace: .recovery
    )
    
    static let strengthEcxercise: any Exercise = StrengthExercise(
        id: "",
        name: "Strength Exercise",
        muscleGroup: .fullBody,
        sets: 3,
        reps: 15,
        weightKg: 100
    )
}

struct ResultRowSnapshotCase {
    let name: String
    let makeView: () -> WorkoutResultRow
}
