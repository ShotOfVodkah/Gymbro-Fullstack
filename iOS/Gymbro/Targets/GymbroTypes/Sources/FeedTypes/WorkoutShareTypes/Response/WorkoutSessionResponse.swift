import Foundation

public struct WorkoutSessionExerciseResponse: Decodable {
    public let id: String
    public let name: String
    public let type: String
    public let muscleGroup: String
    public let sets: Int?
    public let reps: Int?
    public let weightKg: Double?
    public let durationMinutes: Int?
    public let pace: String?
    public let holdSeconds: Int?
    public let breathCount: Int?

    public init(
        id: String,
        name: String,
        type: String,
        muscleGroup: String,
        sets: Int? = nil,
        reps: Int? = nil,
        weightKg: Double? = nil,
        durationMinutes: Int? = nil,
        pace: String? = nil,
        holdSeconds: Int? = nil,
        breathCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.muscleGroup = muscleGroup
        self.sets = sets
        self.reps = reps
        self.weightKg = weightKg
        self.durationMinutes = durationMinutes
        self.pace = pace
        self.holdSeconds = holdSeconds
        self.breathCount = breathCount
    }
}

public struct WorkoutSessionResponse: Decodable {
    public let id: String
    public let userId: String
    public let workoutId: String?
    public let workoutName: String
    public let workoutType: String
    public let completedAt: Date
    public let exercises: [WorkoutSessionExerciseResponse]

    public init(
        id: String,
        userId: String,
        workoutId: String?,
        workoutName: String,
        workoutType: String,
        completedAt: Date,
        exercises: [WorkoutSessionExerciseResponse]
    ) {
        self.id = id
        self.userId = userId
        self.workoutId = workoutId
        self.workoutName = workoutName
        self.workoutType = workoutType
        self.completedAt = completedAt
        self.exercises = exercises
    }
}
