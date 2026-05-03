import Foundation

public enum ChallengeStatus: String, Codable, Hashable {
    case draft
    case upcoming
    case active
    case finished
    case cancelled
    
    public init(rawValue: String) {
        switch rawValue {
        case "draft": self = .draft
        case "upcoming": self = .upcoming
        case "active": self = .active
        case "finished": self = .finished
        case "cancelled": self = .cancelled
        default: self = .draft
        }
    }
}
