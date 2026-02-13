import Foundation

public protocol Exercise {
    
    var id: String { get }
    var name: String { get }
    var muscleGroup: MuscleGroup { get }
    
}

// MARK: - Exercises Variations

public struct StrengthExercise: Exercise {
    public let id: String
    public let name: String
    public let muscleGroup: MuscleGroup
    public let sets: Int
    public let reps: Int
    public let weightKg: Double
    
    public init(
        id: String,
        name: String,
        muscleGroup: MuscleGroup,
        sets: Int,
        reps: Int,
        weightKg: Double
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.sets = sets
        self.reps = reps
        self.weightKg = weightKg
    }
}

public struct CardioExercise: Exercise {
    public let id: String
    public let name: String
    public let muscleGroup: MuscleGroup
    public let durationMinutes: Int
    public let pace: PaceType
    
    public init(
        id: String,
        name: String,
        muscleGroup: MuscleGroup,
        durationMinutes: Int,
        pace: PaceType
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.durationMinutes = durationMinutes
        self.pace = pace
    }
}

public struct YogaExercise: Exercise {
    public let id: String
    public let name: String
    public let muscleGroup: MuscleGroup
    public let holdSeconds: Int
    public let breathCount: Int
    
    public init(
        id: String,
        name: String,
        muscleGroup: MuscleGroup,
        holdSeconds: Int,
        breathCount: Int
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.holdSeconds = holdSeconds
        self.breathCount = breathCount
    }
}

