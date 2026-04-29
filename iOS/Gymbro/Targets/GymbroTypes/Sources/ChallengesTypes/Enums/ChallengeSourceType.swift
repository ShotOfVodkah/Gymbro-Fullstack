import Foundation

public enum ChallengeSourceType: String, Codable, Hashable {
    case workoutSession = "workout_session"
    
    public init(rawValue: String) {
        switch rawValue {
        case "workout_session": self = .workoutSession
        default: self = .workoutSession
        }
    }
}
