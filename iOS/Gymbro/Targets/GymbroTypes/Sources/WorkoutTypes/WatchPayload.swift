
public struct WatchWorkoutPayload: Codable {
    public let id: String
    public let name: String
    public let type: WorkoutType
    public let exercises: [ExerciseItem]

    public init(from workout: Workout) {
        id = workout.id
        name = workout.name
        type = workout.type
        exercises = workout.exercises.map { ExerciseItem(from: $0) }
    }
    
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(WorkoutType.self, forKey: .type)
        self.exercises = try container.decode([ExerciseItem].self, forKey: .exercises)
    }
}

public struct WatchSessionPayload: Codable {
    public let workoutId: String
    public let completedAt: String
    public let exercises: [WatchExerciseResult]
    
    public init(workoutId: String, completedAt: String, exercises: [WatchExerciseResult]) {
        self.workoutId = workoutId
        self.completedAt = completedAt
        self.exercises = exercises
    }
}

public struct WatchExerciseResult: Codable {
    public let exerciseId: String
    public let sets: Int?
    public let reps: Int?
    public let weightKg: Double?
    public let durationMinutes: Int?
    public let pace: String?
    public let holdSeconds: Int?
    public let breathCount: Int?
    
    public init(
        exerciseId: String,
        sets: Int?, reps: Int?,
        weightKg: Double?,
        durationMinutes: Int?,
        pace: String?,
        holdSeconds: Int?,
        breathCount: Int?
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
}
