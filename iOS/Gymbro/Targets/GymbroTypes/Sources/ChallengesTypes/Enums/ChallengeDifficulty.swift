import Foundation

public enum ChallengeDifficulty: String, Codable, Hashable {
    case easy
    case medium
    case hard
    case legendary
    
    public init(rawValue: String) {
        switch rawValue {
        case "easy": self = .easy
        case "medium": self = .medium
        case "hard": self = .hard
        case "legendary": self = .legendary
        default: self = .easy
        }
    }
}
