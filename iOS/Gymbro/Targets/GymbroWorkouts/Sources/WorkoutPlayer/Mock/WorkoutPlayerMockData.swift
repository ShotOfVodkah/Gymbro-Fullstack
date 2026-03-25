import Foundation

import GymbroTypes

enum WorkoutPlayerMockData {

    /// Local preview data instead of a network load; same mixed circuit for any workout id until the API is wired.
    static func workout(for id: String) -> Workout {
        Workout(
            id: id,
            name: "Full body circuit",
            type: .strength,
            exercises: [
                StrengthExercise(
                    id: "ex-1",
                    name: "Barbell bench press",
                    muscleGroup: .chest,
                    sets: 4,
                    reps: 8,
                    weightKg: 60
                ),
                CardioExercise(
                    id: "ex-2",
                    name: "Incline treadmill",
                    muscleGroup: .legs,
                    durationMinutes: 12,
                    pace: .jog
                ),
                StrengthExercise(
                    id: "ex-3",
                    name: "Back squat",
                    muscleGroup: .legs,
                    sets: 4,
                    reps: 10,
                    weightKg: 80
                ),
                YogaExercise(
                    id: "ex-4",
                    name: "Downward dog",
                    muscleGroup: .fullBody,
                    holdSeconds: 45,
                    breathCount: 8
                ),
                CardioExercise(
                    id: "ex-5",
                    name: "Assault bike",
                    muscleGroup: .fullBody,
                    durationMinutes: 5,
                    pace: .sprint
                ),
                YogaExercise(
                    id: "ex-6",
                    name: "Warrior II",
                    muscleGroup: .legs,
                    holdSeconds: 60,
                    breathCount: 10
                ),
                DefaultExercise(
                    id: "ex-7",
                    name: "Cool-down walk",
                    muscleGroup: .fullBody
                ),
            ]
        )
    }
}
