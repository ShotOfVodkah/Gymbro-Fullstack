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

    private enum Kind: String, Codable { case strength, cardio, yoga, fallback }
    private enum CodingKeys: String, CodingKey { case kind, payload }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .strength: self = .strength(try c.decode(StrengthExercise.self, forKey: .payload))
        case .cardio: self = .cardio(try c.decode(CardioExercise.self, forKey: .payload))
        case .yoga: self = .yoga(try c.decode(YogaExercise.self, forKey: .payload))
        case .fallback: self = .fallback(try c.decode(DefaultExercise.self, forKey: .payload))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .strength(let e):
            try c.encode(Kind.strength, forKey: .kind)
            try c.encode(e, forKey: .payload)
        case .cardio(let e):
            try c.encode(Kind.cardio, forKey: .kind)
            try c.encode(e, forKey: .payload)
        case .yoga(let e):
            try c.encode(Kind.yoga, forKey: .kind)
            try c.encode(e, forKey: .payload)
        case .fallback(let e):
            try c.encode(Kind.fallback, forKey: .kind)
            try c.encode(e, forKey: .payload)
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

public extension ExerciseItemDTO {
    init(from exercise: any Exercise) {
        switch exercise {
        case let e as StrengthExercise: self = .strength(e)
        case let e as CardioExercise: self = .cardio(e)
        case let e as YogaExercise: self = .yoga(e)
        case let e as DefaultExercise: self = .fallback(e)
        default:
            self = .fallback(DefaultExercise(id: UUID().uuidString, name: exercise.name, muscleGroup: exercise.muscleGroup))
        }
    }

    var asExercise: any Exercise {
        switch self {
        case .strength(let e): return e
        case .cardio(let e): return e
        case .yoga(let e): return e
        case .fallback(let e): return e
        }
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
