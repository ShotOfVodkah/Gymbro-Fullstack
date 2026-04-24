import GymbroTypes
import SwiftUI

@testable import GymbroWorkouts

enum WorkoutGeneratorResultCardSnapshotExamples {
    static let snapshotSize = CGSize(width: 400, height: 400)

    static let snapshotExamples: [ResultCardSnapshotCase] = [
        ResultCardSnapshotCase(
            name: "yoga_workout",
            makeView: {
                WorkoutResultCard(
                    workout: Workout(
                        id: shortName,
                        name: shortName,
                        type: .yoga,
                        exercises: [
                            yogaEcxercise,
                            yogaEcxercise,
                            yogaEcxercise
                        ]
                    ),
                    dismissAction: {},
                    saveAction: {}
                )
            }
        ),
        ResultCardSnapshotCase(
            name: "cardio_workout",
            makeView: {
                WorkoutResultCard(
                    workout: Workout(
                        id: longName,
                        name: longName,
                        type: .cardio,
                        exercises: [
                            cardioEcxercise,
                            cardioEcxercise,
                            cardioEcxercise,
                            cardioEcxercise,
                            cardioEcxercise
                        ]
                    ),
                    dismissAction: {},
                    saveAction: {}
                )
            }
        ),
        ResultCardSnapshotCase(
            name: "strength_workout",
            makeView: {
                WorkoutResultCard(
                    workout: Workout(
                        id: longName,
                        name: longName,
                        type: .strength,
                        exercises: [
                            strengthEcxercise,
                            strengthEcxercise,
                            strengthEcxercise,
                            strengthEcxercise
                        ]
                    ),
                    dismissAction: {},
                    saveAction: {}
                )
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

struct ResultCardSnapshotCase {
    let name: String
    let makeView: () -> WorkoutResultCard
}
