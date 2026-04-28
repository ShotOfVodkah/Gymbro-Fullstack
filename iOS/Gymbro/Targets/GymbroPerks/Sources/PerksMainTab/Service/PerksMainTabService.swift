import Foundation
import GymbroTypes

protocol PerksMainTabService {
    func fetchDashboard() async throws -> PerksDashboard
    func updateWeeklyGoal(_ goal: Int) async throws -> PerksDashboard
    func useStreakFreeze() async throws -> PerksDashboard
}

final class PerksMainTabServiceImpl: PerksMainTabService {
    
    private var dashboard = PerksMockData.dashboard
    
    init() { // client: FeedsClient
        //        self.client = client
    }
    
    func fetchDashboard() async throws -> PerksDashboard {
        try await Task.sleep(nanoseconds: 500_000_000)
        return PerksMockData.dashboard
    }
    
    func updateWeeklyGoal(_ goal: Int) async throws -> PerksDashboard {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let oldStreak = dashboard.streak
        
        let updatedStreak = StreakState(
            currentStreakWeeks: oldStreak.currentStreakWeeks,
            bestStreakWeeks: oldStreak.bestStreakWeeks,
            weeklyGoal: oldStreak.weeklyGoal,
            nextWeeklyGoal: goal,
            completedThisWeek: oldStreak.completedThisWeek,
            remainingToGoal: oldStreak.remainingToGoal,
            weekStartDate: oldStreak.weekStartDate,
            weekEndDate: oldStreak.weekEndDate,
            isGoalCompleted: oldStreak.isGoalCompleted,
            streakFreezeCount: oldStreak.streakFreezeCount,
            canUseStreakFreeze: oldStreak.canUseStreakFreeze,
            wasFreezeUsedThisWeek: oldStreak.wasFreezeUsedThisWeek
        )
        
        dashboard = PerksDashboard(
            streak: updatedStreak,
            recentUnlocks: dashboard.recentUnlocks,
            achievements: dashboard.achievements,
            leaderboardPreview: dashboard.leaderboardPreview,
            myRank: dashboard.myRank
        )
        
        return dashboard
    }
    
    func useStreakFreeze() async throws -> PerksDashboard {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let oldStreak = dashboard.streak
        let updatedFreezeCount = max(oldStreak.streakFreezeCount - 1, 0)
        
        let updatedStreak = StreakState(
            currentStreakWeeks: oldStreak.currentStreakWeeks,
            bestStreakWeeks: oldStreak.bestStreakWeeks,
            weeklyGoal: oldStreak.weeklyGoal,
            nextWeeklyGoal: oldStreak.nextWeeklyGoal,
            completedThisWeek: oldStreak.completedThisWeek,
            remainingToGoal: oldStreak.remainingToGoal,
            weekStartDate: oldStreak.weekStartDate,
            weekEndDate: oldStreak.weekEndDate,
            isGoalCompleted: oldStreak.isGoalCompleted,
            streakFreezeCount: updatedFreezeCount,
            canUseStreakFreeze: false,
            wasFreezeUsedThisWeek: true
        )
        
        dashboard = PerksDashboard(
            streak: updatedStreak,
            recentUnlocks: dashboard.recentUnlocks,
            achievements: dashboard.achievements,
            leaderboardPreview: dashboard.leaderboardPreview,
            myRank: dashboard.myRank
        )
        
        return dashboard
    }
    
    //    private let client: FeedsClient
}
