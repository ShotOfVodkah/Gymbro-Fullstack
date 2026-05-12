import SwiftUI

public enum ChallengeParticipationStatus: String, Codable, Hashable {
    case notJoined = "not_joined"
    case inProgress = "in_progress"
    case completed
    case failed
    
    public init(rawValue: String) {
        switch rawValue {
        case "not_joined": self = .notJoined
        case "in_progress": self = .inProgress
        case "completed": self = .completed
        case "failed": self = .failed
        default: self = .notJoined
        }
    }
    
    public var title: String {
        switch self {
        case .notJoined:
            return String(localized: "challenge.status.not_joined", bundle: .module)
        case .inProgress:
            return String(localized: "challenge.status.in_progress", bundle: .module)
        case .completed:
            return String(localized: "challenge.status.completed", bundle: .module)
        case .failed:
            return String(localized: "challenge.status.failed", bundle: .module)
        }
    }
    
    public var colorName: String {
        switch self {
        case .notJoined: return "blue"
        case .inProgress: return "orange"
        case .completed: return "green"
        case .failed: return "red"
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .notJoined:
            return .blue
        case .inProgress:
            return .orange
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
}
