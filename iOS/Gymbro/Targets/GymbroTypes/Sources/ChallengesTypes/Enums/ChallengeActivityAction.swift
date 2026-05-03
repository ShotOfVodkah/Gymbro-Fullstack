import Foundation

public enum ChallengeActivityAction: String, Codable, Hashable {
    case completedWorkout = "completed_workout"
    case joinedChallenge = "joined_challenge"
    case completedChallenge = "completed_challenge"
    case failedChallenge = "failed_challenge"
    
    public init(rawValue: String) {
        switch rawValue {
        case "completed_workout": self = .completedWorkout
        case "joined_challenge": self = .joinedChallenge
        case "completed_challenge": self = .completedChallenge
        case "failed_challenge": self = .failedChallenge
        default: self = .completedWorkout
        }
    }
}
