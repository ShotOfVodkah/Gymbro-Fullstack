import Foundation

public struct PerksDashboard: Equatable {
    public let streak: StreakState
    public let recentUnlocks: [Achievement]
    public let achievements: [Achievement]
    public var leaderboardPreview: [LeaderboardEntry]
    public let myRank: MyRank?
    
    public init(
        streak: StreakState,
        recentUnlocks: [Achievement],
        achievements: [Achievement],
        leaderboardPreview: [LeaderboardEntry],
        myRank: MyRank?
    ) {
        self.streak = streak
        self.recentUnlocks = recentUnlocks
        self.achievements = achievements
        self.leaderboardPreview = leaderboardPreview
        self.myRank = myRank
    }
}

public extension PerksDashboardResponse {
    
    func toModel() -> PerksDashboard {
        PerksDashboard(
            streak: streak.toModel(),
            recentUnlocks: recentUnlocks.map { $0.toModel() },
            achievements: achievements.map { $0.toModel() },
            leaderboardPreview: leaderboardPreview.map { $0.toModel() },
            myRank: myRank?.toModel()
        )
    }
}
