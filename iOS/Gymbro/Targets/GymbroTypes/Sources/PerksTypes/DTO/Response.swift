import Foundation

public struct PerksDashboardResponse: Decodable, Sendable {
    public let streak: StreakResponse
    public let recentUnlocks: [AchievementResponse]
    public let achievements: [AchievementResponse]
    public let leaderboardPreview: [LeaderboardResponse]
    public let myRank: MyRankResponse?
}

public struct StreakResponse: Decodable, Sendable {
    public let currentStreakWeeks: Int
    public let bestStreakWeeks: Int
    
    public let weeklyGoal: Int
    public let nextWeeklyGoal: Int?
    
    public let completedThisWeek: Int
    public let remainingToGoal: Int
    
    public let weekStartDate: Date
    public let weekEndDate: Date
    
    public let isGoalCompleted: Bool
    
    public let streakFreezeCount: Int
    public let canUseStreakFreeze: Bool
    public let wasFreezeUsedThisWeek: Bool
}

public struct AchievementResponse: Decodable, Sendable {
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
}

public struct LeaderboardResponse: Decodable, Sendable {
    public let id: String
    public let rank: Int
    
    public let userID: String
    public let name: String
    public let username: String
    public let avatarSystemName: String
    
    public let currentStreakWeeks: Int
    public let completedWorkouts: Int
    
    public let isCurrentUser: Bool
    public let isFollowing: Bool
    public let isFriend: Bool
}

public struct MyRankResponse: Decodable, Sendable {
    public let rank: Int
    public let currentStreakWeeks: Int
    public let completedWorkouts: Int
}
