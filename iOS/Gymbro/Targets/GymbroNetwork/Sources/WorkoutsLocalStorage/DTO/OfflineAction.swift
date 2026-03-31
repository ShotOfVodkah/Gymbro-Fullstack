import Foundation
import GymbroTypes

public enum OfflineActionDTO: Codable, Equatable {
    case premadeAdded(id: String)
    case addedWorkout(workout: WorkoutDTO)
    case editedWorkout(workout: WorkoutDTO)
    case deletedWorkout(id: String)
    case completedWorkout(id: String, exercises: [WorkoutExerciseRequest])

    private enum Kind: String, Codable {
        case premadeAdded, addedWorkout, editedWorkout, deletedWorkout, completedWorkout
    }
    private enum CodingKeys: String, CodingKey { case kind, id, workout, exercises }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)

        switch kind {
        case .premadeAdded:
            self = .premadeAdded(id: try c.decode(String.self, forKey: .id))
        case .addedWorkout:
            self = .addedWorkout(workout: try c.decode(WorkoutDTO.self, forKey: .workout))
        case .editedWorkout:
            self = .editedWorkout(workout: try c.decode(WorkoutDTO.self, forKey: .workout))
        case .deletedWorkout:
            self = .deletedWorkout(id: try c.decode(String.self, forKey: .id))
        case .completedWorkout:
            self = .completedWorkout(
                id: try c.decode(String.self, forKey: .id),
                exercises: try c.decode([WorkoutExerciseRequest].self, forKey: .exercises)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .premadeAdded(let id):
            try c.encode(Kind.premadeAdded, forKey: .kind)
            try c.encode(id, forKey: .id)

        case .addedWorkout(let workout):
            try c.encode(Kind.addedWorkout, forKey: .kind)
            try c.encode(workout, forKey: .workout)

        case .editedWorkout(let workout):
            try c.encode(Kind.editedWorkout, forKey: .kind)
            try c.encode(workout, forKey: .workout)

        case .deletedWorkout(let id):
            try c.encode(Kind.deletedWorkout, forKey: .kind)
            try c.encode(id, forKey: .id)

        case .completedWorkout(let id, let exercises):
            try c.encode(Kind.completedWorkout, forKey: .kind)
            try c.encode(id, forKey: .id)
            try c.encode(exercises, forKey: .exercises)
        }
    }
}
