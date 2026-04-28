import Foundation

public struct StreakState: Equatable {
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
    
    public var hasPendingGoalChange: Bool {
        guard let nextWeeklyGoal else { return false }
        return nextWeeklyGoal != weeklyGoal
    }
    
    public init(
        currentStreakWeeks: Int,
        bestStreakWeeks: Int,
        weeklyGoal: Int,
        nextWeeklyGoal: Int?,
        completedThisWeek: Int,
        remainingToGoal: Int,
        weekStartDate: Date,
        weekEndDate: Date,
        isGoalCompleted: Bool,
        streakFreezeCount: Int,
        canUseStreakFreeze: Bool,
        wasFreezeUsedThisWeek: Bool
    ) {
        self.currentStreakWeeks = currentStreakWeeks
        self.bestStreakWeeks = bestStreakWeeks
        self.weeklyGoal = weeklyGoal
        self.nextWeeklyGoal = nextWeeklyGoal
        self.completedThisWeek = completedThisWeek
        self.remainingToGoal = remainingToGoal
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.isGoalCompleted = isGoalCompleted
        self.streakFreezeCount = streakFreezeCount
        self.canUseStreakFreeze = canUseStreakFreeze
        self.wasFreezeUsedThisWeek = wasFreezeUsedThisWeek
    }
}

public extension StreakResponse {
    
    func toModel() -> StreakState {
        StreakState(
            currentStreakWeeks: currentStreakWeeks,
            bestStreakWeeks: bestStreakWeeks,
            weeklyGoal: weeklyGoal,
            nextWeeklyGoal: nextWeeklyGoal,
            completedThisWeek: completedThisWeek,
            remainingToGoal: remainingToGoal,
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            isGoalCompleted: isGoalCompleted,
            streakFreezeCount: streakFreezeCount,
            canUseStreakFreeze: canUseStreakFreeze,
            wasFreezeUsedThisWeek: wasFreezeUsedThisWeek
        )
    }
}
