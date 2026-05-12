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
            return String(localized: "achievement.category.all", bundle: .module)
        case .workoutMilestones:
            return String(localized: "achievement.category.milestones", bundle: .module)
        case .consistency:
            return String(localized: "achievement.category.consistency", bundle: .module)
        case .timeChallenges:
            return String(localized: "achievement.category.time", bundle: .module)
        case .social:
            return String(localized: "achievement.category.social", bundle: .module)
        case .special:
            return String(localized: "achievement.category.special", bundle: .module)
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
            return String(localized: "achievement.rarity.common", bundle: .module)
        case .rare:
            return String(localized: "achievement.rarity.rare", bundle: .module)
        case .epic:
            return String(localized: "achievement.rarity.epic", bundle: .module)
        case .legendary:
            return String(localized: "achievement.rarity.legendary", bundle: .module)
        }
    }
}

public enum AchievementStatus: String, Codable, Sendable {
    case locked
    case unlocked
}
