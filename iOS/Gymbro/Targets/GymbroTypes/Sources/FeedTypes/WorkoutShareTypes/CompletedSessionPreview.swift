import Foundation

public struct CompletedSessionPreview: Equatable {
    public let sessionID: String
    public let workoutID: String?
    public let title: String
    public let category: String
    public let durationMinutes: Int?
    public let durationText: String?
    public let exerciseCount: Int
    public let exercisesPreview: [ExerciseItem]

    public init(
        sessionID: String,
        workoutID: String? = nil,
        title: String,
        category: String,
        durationMinutes: Int? = nil,
        durationText: String? = nil,
        exerciseCount: Int,
        exercisesPreview: [ExerciseItem]
    ) {
        self.sessionID = sessionID
        self.workoutID = workoutID
        self.title = title
        self.category = category
        self.durationMinutes = durationMinutes
        self.durationText = durationText
        self.exerciseCount = exerciseCount
        self.exercisesPreview = exercisesPreview
    }
}

extension CompletedSessionPreview {
    public init?(feedResponse: FeedPostItemResponse) {
        guard let workout = feedResponse.workout else { return nil }

        self.init(
            sessionID: feedResponse.id,
            workoutID: workout.id,
            title: workout.title,
            category: workout.category,
            durationMinutes: workout.duration_minutes,
            durationText: "\(workout.duration_minutes) min",
            exerciseCount: workout.exercise_count,
            exercisesPreview: workout.exercises_preview.map(Self.mapFeedExercise)
        )
    }

    private static func mapFeedExercise(_ item: FeedWorkoutExercisePreviewResponse) -> ExerciseItem {
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

extension CompletedSessionPreview {
    public init(chatWorkout response: ChatWorkoutAttachmentResponse) {
        self.init(
            sessionID: response.session_id ?? "",
            workoutID: nil,
            title: response.title,
            category: response.category,
            durationMinutes: nil,
            durationText: response.duration,
            exerciseCount: 0,
            exercisesPreview: []
        )
    }
}
