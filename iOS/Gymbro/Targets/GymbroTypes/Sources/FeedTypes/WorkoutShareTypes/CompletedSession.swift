import Foundation

public struct CompletedSession: Hashable, Identifiable {
    public let id: String
    public let userID: String
    public let workoutID: String
    public let completedAt: Date
    public let exercises: [ExerciseItem]

    public init(
        id: String,
        userID: String,
        workoutID: String,
        completedAt: Date,
        exercises: [ExerciseItem]
    ) {
        self.id = id
        self.userID = userID
        self.workoutID = workoutID
        self.completedAt = completedAt
        self.exercises = exercises
    }
    
    public static func == (lhs: CompletedSession, rhs: CompletedSession) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CompletedSession {
    public init(response: WorkoutSessionResponse) {
        self.init(
            id: response.id,
            userID: response.userId,
            workoutID: response.workoutId ?? "",
            completedAt: response.completedAt,
            exercises: response.exercises.map(Self.mapExercise)
        )
    }

    private static func mapExercise(_ item: WorkoutSessionExerciseResponse) -> ExerciseItem {
        let muscleGroup: MuscleGroup = switch item.muscleGroup {
        case "chest": .chest
        case "back": .back
        case "shoulders": .shoulders
        case "biceps": .biceps
        case "triceps": .triceps
        case "legs": .legs
        case "glutes": .glutes
        case "core": .core
        case "full_body": .fullBody
        default: .fullBody
        }

        switch item.type {
        case "strength":
            return .strength(
                StrengthExercise(
                    id: item.id,
                    name: item.name,
                    muscleGroup: muscleGroup,
                    sets: item.sets ?? 0,
                    reps: item.reps ?? 0,
                    weightKg: item.weightKg ?? 0
                )
            )
        case "cardio":
            return .cardio(
                CardioExercise(
                    id: item.id,
                    name: item.name,
                    muscleGroup: muscleGroup,
                    durationMinutes: item.durationMinutes ?? 0,
                    pace: {
                        switch item.pace {
                        case "walk": return .walk
                        case "run": return .run
                        case "sprint": return .sprint
                        case "recovery": return .recovery
                        default: return .jog
                        }
                    }()
                )
            )
        case "yoga":
            return .yoga(
                YogaExercise(
                    id: item.id,
                    name: item.name,
                    muscleGroup: muscleGroup,
                    holdSeconds: item.holdSeconds ?? 0,
                    breathCount: item.breathCount ?? 0
                )
            )
        default:
            return .fallback(
                DefaultExercise(
                    id: item.id,
                    name: item.name,
                    muscleGroup: muscleGroup
                )
            )
        }
    }
}
