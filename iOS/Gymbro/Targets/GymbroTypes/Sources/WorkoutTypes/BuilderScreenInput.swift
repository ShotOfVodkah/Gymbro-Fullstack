import Foundation

public enum BuilderScreenInput: Hashable {
    case new(type: String)
    case existing(workout: Workout)
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.new(let l), .new(let r)):
            return l == r
        case (.existing(let l), .existing(let r)):
            return l.id == r.id
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .new(let type):
            hasher.combine("new")
            hasher.combine(type)
        case .existing(let workout):
            hasher.combine("existing")
            hasher.combine(workout.id)
        }
    }
}
