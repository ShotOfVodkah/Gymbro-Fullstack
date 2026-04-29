import Foundation

public enum ChallengeUnit: String, Codable, Hashable {
    case workouts
    case minutes
    case calories
    case days
    
    public init(rawValue: String) {
        switch rawValue {
        case "workouts": self = .workouts
        case "minutes": self = .minutes
        case "calories": self = .calories
        case "days": self = .days
        default: self = .workouts
        }
    }
}
