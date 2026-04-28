import Foundation

public struct Achievement: Identifiable, Hashable {
    public let id: String
    public let code: String
    
    public let name: String
    public let description: String
    public let iconName: String
    
    public let category: AchievementCategory
    public let rarity: AchievementRarity
    public let status: AchievementStatus
    
    public let progressCurrent: Int
    public let progressTarget: Int
    
    public let unlockedAt: Date?
    public let isSecret: Bool
    
    public var isUnlocked: Bool {
        status == .unlocked
    }
    
    public var progress: Double {
        guard progressTarget > 0 else { return 0 }
        return min(Double(progressCurrent) / Double(progressTarget), 1)
    }
    
    public init(
        id: String,
        code: String,
        name: String,
        description: String,
        iconName: String,
        category: AchievementCategory,
        rarity: AchievementRarity,
        status: AchievementStatus,
        progressCurrent: Int,
        progressTarget: Int,
        unlockedAt: Date?,
        isSecret: Bool
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.description = description
        self.iconName = iconName
        self.category = category
        self.rarity = rarity
        self.status = status
        self.progressCurrent = progressCurrent
        self.progressTarget = progressTarget
        self.unlockedAt = unlockedAt
        self.isSecret = isSecret
    }
}

public extension AchievementResponse {
    
    func toModel() -> Achievement {
        Achievement(
            id: id,
            code: code,
            name: name,
            description: description,
            iconName: iconName,
            category: category,
            rarity: rarity,
            status: status,
            progressCurrent: progressCurrent,
            progressTarget: progressTarget,
            unlockedAt: unlockedAt,
            isSecret: isSecret
        )
    }
}
