import Foundation

public struct WorkoutExerciseRequest: Encodable, Decodable, Equatable {
    public let exerciseId: String
    public let sets: Int?
    public let reps: Int?
    public let weightKg: Double?
    public let durationMinutes: Int?
    public let pace: PaceType?
    public let holdSeconds: Int?
    public let breathCount: Int?

    public init(
        exerciseId: String,
        sets: Int? = nil,
        reps: Int? = nil,
        weightKg: Double? = nil,
        durationMinutes: Int? = nil,
        pace: PaceType? = nil,
        holdSeconds: Int? = nil,
        breathCount: Int? = nil
    ) {
        self.exerciseId = exerciseId
        self.sets = sets
        self.reps = reps
        self.weightKg = weightKg
        self.durationMinutes = durationMinutes
        self.pace = pace
        self.holdSeconds = holdSeconds
        self.breathCount = breathCount
    }

    public init(from exercise: any Exercise) {
        switch exercise {
        case let e as StrengthExercise:
            self.init(exerciseId: e.id, sets: e.sets, reps: e.reps, weightKg: e.weightKg)
        case let e as CardioExercise:
            self.init(exerciseId: e.id, durationMinutes: e.durationMinutes, pace: e.pace)
        case let e as YogaExercise:
            self.init(exerciseId: e.id, holdSeconds: e.holdSeconds, breathCount: e.breathCount)
        default:
            self.init(exerciseId: exercise.id)
        }
    }
}

public struct CreateWorkoutRequest: Encodable {
    public let id: String
    public let userId: String
    public let name: String
    public let type: WorkoutType
    public let exercises: [WorkoutExerciseRequest]
    
    public init(
        id: String,
        userId: String,
        name: String,
        type: WorkoutType,
        exercises: [WorkoutExerciseRequest]
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.exercises = exercises
    }
}

public struct UpdateWorkoutRequest: Encodable {
    public let name: String
    public let type: WorkoutType
    public let exercises: [WorkoutExerciseRequest]
    
    public init(
        name: String,
        type: WorkoutType,
        exercises: [WorkoutExerciseRequest]
    ) {
        self.name = name
        self.type = type
        self.exercises = exercises
    }
}

public struct CreateSessionRequest: Encodable {
    public let id: String
    public let userId: String
    public let workoutId: String
    public let completedAt: String
    public let exercises: [WorkoutExerciseRequest]
    
    public init(
        id: String,
        userId: String,
        workoutId: String,
        completedAt: String,
        exercises: [WorkoutExerciseRequest]
    ) {
        self.id = id
        self.userId = userId
        self.workoutId = workoutId
        self.completedAt = completedAt
        self.exercises = exercises
    }
}

public struct GenerateWorkoutRequest: Encodable {
    public let user_input: String
    public let injuries: [String]
    public let user_id: String
    
    public init(
        user_input: String,
        injuries: [String],
        user_id: String
    ) {
        self.user_input = user_input
        self.injuries = injuries
        self.user_id = user_id
    }
}
