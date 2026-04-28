import Foundation

public enum AchievementCategory: String, Codable, Sendable, CaseIterable, Identifiable {
    case all
    case workoutMilestones
    case consistency
    case timeChallenges
    case social
    case special
    
    public var id: String {
        rawValue
    }
    
    public var title: String {
        switch self {
        case .all:
            return "All"
        case .workoutMilestones:
            return "Milestones"
        case .consistency:
            return "Consistency"
        case .timeChallenges:
            return "Time"
        case .social:
            return "Social"
        case .special:
            return "Special"
        }
    }
}

public enum AchievementRarity: String, Codable, Sendable, CaseIterable {
    case common
    case rare
    case epic
    case legendary
    
    public var title: String {
        switch self {
        case .common:
            return "Common"
        case .rare:
            return "Rare"
        case .epic:
            return "Epic"
        case .legendary:
            return "Legendary"
        }
    }
}

public enum AchievementStatus: String, Codable, Sendable {
    case locked
    case unlocked
}
