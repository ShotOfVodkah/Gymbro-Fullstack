import GymbroTypes
import Foundation

public struct WorkoutDTO: Codable, Equatable {
    public let userId: String
    public let id: String
    public let name: String
    public let type: WorkoutType
    public let exercises: [ExerciseItemDTO]
}

public enum ExerciseItemDTO: Codable, Equatable {
    case strength(StrengthExercise)
    case cardio(CardioExercise)
    case yoga(YogaExercise)
    case fallback(DefaultExercise)

    private enum AllKeys: String, CodingKey {
        case id, name, type, muscleGroup
        case sets, reps, weightKg
        case durationMinutes, pace
        case holdSeconds, breathCount
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AllKeys.self)
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AllKeys.self)
        
        switch self {
        case .strength(let e):
            try container.encode("strength", forKey: .type)
            try e.encode(to: encoder)
        case .cardio(let e):
            try container.encode("cardio", forKey: .type)
            try e.encode(to: encoder)
        case .yoga(let e):
            try container.encode("yoga", forKey: .type)
            try e.encode(to: encoder)
        case .fallback(let e):
            try container.encode("fallback", forKey: .type)
            try e.encode(to: encoder)
        }
    }
    
    public var asExercise: any Exercise {
        switch self {
        case .strength(let e): return e
        case .cardio(let e): return e
        case .yoga(let e): return e
        case .fallback(let e): return e
        }
    }
    
    public init(from exercise: any Exercise) {
        switch exercise {
        case let e as StrengthExercise: self = .strength(e)
        case let e as CardioExercise: self = .cardio(e)
        case let e as YogaExercise: self = .yoga(e)
        case let e as DefaultExercise: self = .fallback(e)
        default:
            self = .fallback(DefaultExercise(id: UUID().uuidString, name: exercise.name, muscleGroup: exercise.muscleGroup))
        }
    }
}

public extension WorkoutDTO {
    init(from workout: Workout) {
        self.userId = workout.userId
        self.id = workout.id
        self.name = workout.name
        self.type = workout.type
        self.exercises = workout.exercises.map { ExerciseItemDTO(from: $0) }
    }

    func toWorkout() -> Workout {
        let exercisesAny: [any Exercise] = exercises.map { $0.asExercise }
        return Workout(userId: userId, id: id, name: name, type: type, exercises: exercisesAny)
    }
}

public enum AvailableExercisesKey {
    case strength
    case cardio
    case yoga

    public var rawKey: String {
        switch self {
        case .strength: return "available_exercises_strength"
        case .cardio:   return "available_exercises_cardio"
        case .yoga:     return "available_exercises_yoga"
        }
    }

    public init(workoutType: WorkoutType) {
        switch workoutType {
        case .strength: self = .strength
        case .cardio: self = .cardio
        case .yoga: self = .yoga
        }
    }
}
