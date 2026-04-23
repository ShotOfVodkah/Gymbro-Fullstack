import GymbroTypes
import SwiftUI

@testable import GymbroWorkouts

enum WorkoutPlayerExerciseSlideViewSnapshotExamples {
    static let snapshotSize = CGSize(width: 390, height: 600)

    static let snapshotExamples: [SnapshotCase] = [
        SnapshotCase(
            name: "strength",
            makeView: {
                WorkoutPlayerExerciseSlideView(
                    exercise: .strength(
                        StrengthExercise(
                            id: "strength-1",
                            name: "Bench press",
                            muscleGroup: .chest,
                            sets: 3,
                            reps: 8,
                            weightKg: 60.5
                        )
                    ),
                    onNext: nil,
                    onWeightChanged: nil
                )
            }
        ),
        SnapshotCase(
            name: "cardio",
            makeView: {
                WorkoutPlayerExerciseSlideView(
                    exercise: .cardio(
                        CardioExercise(
                            id: "cardio-1",
                            name: "Treadmill",
                            muscleGroup: .legs,
                            durationMinutes: 5,
                            pace: .jog
                        )
                    ),
                    onNext: nil,
                    onWeightChanged: nil
                )
            }
        ),
        SnapshotCase(
            name: "yoga",
            makeView: {
                WorkoutPlayerExerciseSlideView(
                    exercise: .yoga(
                        YogaExercise(
                            id: "yoga-1",
                            name: "Cobra",
                            muscleGroup: .core,
                            holdSeconds: 45,
                            breathCount: 4
                        )
                    ),
                    onNext: nil,
                    onWeightChanged: nil
                )
            }
        ),
        SnapshotCase(
            name: "fallback",
            makeView: {
                WorkoutPlayerExerciseSlideView(
                    exercise: .fallback(
                        DefaultExercise(
                            id: "fb-1",
                            name: "Session note",
                            muscleGroup: .fullBody
                        )
                    ),
                    onNext: nil,
                    onWeightChanged: nil
                )
            }
        )
    ]
}

struct SnapshotCase {
    let name: String
    let makeView: () -> WorkoutPlayerExerciseSlideView
}
