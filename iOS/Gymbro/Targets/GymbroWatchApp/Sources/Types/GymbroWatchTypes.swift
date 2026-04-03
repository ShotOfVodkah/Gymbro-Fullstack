import SwiftUI

struct WatchWorkoutPayload: Codable {
    let id: String
    let name: String
    let type: WorkoutType
    let exercises: [ExerciseItem]
}

struct WatchSessionPayload: Codable {
    let workoutId: String
    let completedAt: String
    let exercises: [WatchExerciseResult]
}

struct WatchExerciseResult: Codable {
    let exerciseId: String
    let sets: Int?
    let reps: Int?
    let weightKg: Double?
    let durationMinutes: Int?
    let pace: String?
    let holdSeconds: Int?
    let breathCount: Int?
}

enum WorkoutType: String, Codable {
    case strength
    case cardio
    case yoga
}

enum PaceType: String, Codable {
    case walk, jog, run, sprint, recovery
}

enum MuscleGroup: String, Codable {
    case chest, back, shoulders, biceps, triceps, legs, glutes, core
    case fullBody = "full_body"
}

protocol Exercise: Identifiable, Codable {
    var id: String { get }
    var name: String { get }
    var muscleGroup: MuscleGroup { get }
}

struct StrengthExercise: Exercise {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
    let defaultSets: Int?
    let defaultReps: Int?
    let defaultWeightKg: Double?
}

struct CardioExercise: Exercise {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
    let defaultDurationMinutes: Int?
    let defaultPace: PaceType?
}

struct YogaExercise: Exercise {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
    let defaultHoldSeconds: Int?
    let defaultBreathCount: Int?
}

struct DefaultExercise: Exercise {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
}

enum ExerciseItem: Codable, Identifiable {
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
