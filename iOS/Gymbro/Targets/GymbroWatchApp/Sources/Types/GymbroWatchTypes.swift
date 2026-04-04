import SwiftUI

struct WatchWorkoutPayload: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let type: WorkoutType
    let exercises: [ExerciseItem]
}

struct WatchSessionPayload: Codable, Hashable {
    let workoutId: String
    let completedAt: String
    let exercises: [WatchExerciseResult]
}

struct WatchExerciseResult: Codable, Hashable {
    let exerciseId: String
    let sets: Int?
    let reps: Int?
    let weightKg: Double?
    let durationMinutes: Int?
    let pace: String?
    let holdSeconds: Int?
    let breathCount: Int?
    
    init(
        exerciseId: String,
        sets: Int? = nil,
        reps: Int? = nil,
        weightKg: Double? = nil,
        durationMinutes: Int? = nil,
        pace: String? = nil,
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
}

enum WorkoutType: String, Codable, Hashable {
    case strength
    case cardio
    case yoga
    
    public var title: String {
        switch self {
        case .strength: return "Strength"
        case .cardio: return "Cardio"
        case .yoga: return "Yoga"
        }
    }
    
    public var image: String {
        switch self {
        case .strength: return "strength"
        case .cardio: return "cardio"
        case .yoga: return "yoga"
        }
    }
    
    public var color: Color {
        switch self {
        case .strength: return .strengthColor
        case .cardio: return .cardioColor
        case .yoga: return .yogaColor
        }
    }
}

enum PaceType: String, Codable, Hashable {
    case walk, jog, run, sprint, recovery
    
    public var title: String {
        switch self {
        case .walk: return "Walk"
        case .jog: return "Jog"
        case .run: return "Run"
        case .sprint: return "Sprint"
        case .recovery: return "Recovery"
        }
    }
}

enum MuscleGroup: String, Codable, Hashable {
    case chest, back, shoulders, biceps, triceps, legs, glutes, core
    case fullBody = "full_body"
}

protocol Exercise: Identifiable, Codable, Hashable {
    var id: String { get }
    var name: String { get }
    var muscleGroup: MuscleGroup { get }
}

struct StrengthExercise: Exercise {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
    let sets: Int
    let reps: Int
    let weightKg: Double
}

struct CardioExercise: Exercise {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
    let durationMinutes: Int
    let pace: PaceType
}

struct YogaExercise: Exercise {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
    let holdSeconds: Int
    let breathCount: Int
}

struct DefaultExercise: Exercise {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
}

enum ExerciseItem: Codable, Identifiable, Hashable {
    case strength(StrengthExercise)
    case cardio(CardioExercise)
    case yoga(YogaExercise)
    case fallback(DefaultExercise)
    
    var id: String {
        switch self {
        case .strength(let e): return e.id
        case .cardio(let e): return e.id
        case .yoga(let e): return e.id
        case .fallback(let e): return e.id
        }
    }
    
    var name: String {
        switch self {
        case .strength(let e): return e.name
        case .cardio(let e): return e.name
        case .yoga(let e): return e.name
        case .fallback(let e): return e.name
        }
    }
    
    var muscleGroup: MuscleGroup {
        switch self {
        case .strength(let e): return e.muscleGroup
        case .cardio(let e): return e.muscleGroup
        case .yoga(let e): return e.muscleGroup
        case .fallback(let e): return e.muscleGroup
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "strength":
            self = .strength(try StrengthExercise(from: decoder))
        case "cardio":
            self = .cardio(try CardioExercise(from: decoder))
        case "yoga":
            self = .yoga(try YogaExercise(from: decoder))
        default:
            self = .fallback(try DefaultExercise(from: decoder))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .strength(let exercise):
            try container.encode("strength", forKey: .type)
            try exercise.encode(to: encoder)
        case .cardio(let exercise):
            try container.encode("cardio", forKey: .type)
            try exercise.encode(to: encoder)
        case .yoga(let exercise):
            try container.encode("yoga", forKey: .type)
            try exercise.encode(to: encoder)
        case .fallback(let exercise):
            try container.encode("fallback", forKey: .type)
            try exercise.encode(to: encoder)
        }
    }
}

extension Color {
    public static let appPurple = Color(red: 115/255, green: 42/255, blue: 255/255)
    public static let appRed =  Color(red: 229/255, green: 57/255, blue: 53/255)
    public static let appDarkGray = Color(red: 29/255, green: 29/255, blue: 52/255)
    public static let strengthColor = Color(red: 46/255, green: 39/255, blue: 255/255)
    public static let cardioColor = Color(red: 188/255, green: 49/255, blue: 207/255)
    public static let yogaColor = Color(red: 115/255, green: 255/255, blue: 122/255)
}
