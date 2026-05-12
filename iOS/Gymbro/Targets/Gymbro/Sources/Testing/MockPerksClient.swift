import Foundation
import GymbroNetwork
import GymbroTypes

final class MockPerksClient: PerksClient {

    private var arguments: [String] {
        ProcessInfo.processInfo.arguments
    }

    func fetchDashboard() async throws -> PerksDashboardResponse {
        try MockDecoder.decode(buildDashboardJSON())
    }

    func fetchStreak() async throws -> StreakResponse {
        try await fetchDashboard().streak
    }

    func updateWeeklyGoal(_ request: UpdateWeeklyGoalRequest) async throws -> PerksDashboardResponse {
        try await fetchDashboard()
    }

    func useStreakFreeze(_ request: UseStreakFreezeRequest) async throws -> PerksDashboardResponse {
        try await fetchDashboard()
    }

    func fetchAchievements() async throws -> [AchievementResponse] {
        try await fetchDashboard().achievements
    }

    func fetchLeaderboard(filter: LeaderboardFilter, sort: LeaderboardSort) async throws -> [LeaderboardResponse] {
        try await fetchDashboard().leaderboardPreview
    }

    func sendPerksEvent(_ request: PerksEventRequest) async throws {}

    // MARK: - JSON

    private func buildDashboardJSON() -> String {
        """
        {
          "streak": \(streakJSONObject()),
          "recentUnlocks": \(Self.recentUnlocksJSON),
          "achievements": \(Self.achievementsJSON),
          "leaderboardPreview": \(Self.leaderboardPreviewJSON),
          "myRank": \(Self.myRankJSON)
        }
        """
    }

    private func streakJSONObject() -> String {
        if arguments.contains("-uitest-perks-streak-completed") {
            return Self.streakCompletedJSON
        }
        if arguments.contains("-uitest-perks-streak-freeze") {
            return Self.streakFreezeJSON
        }
        if arguments.contains("-uitest-perks-streak-danger") {
            return Self.streakDangerJSON()
        }
        return Self.streakDefaultJSON()
    }

    private static func streakDefaultJSON() -> String {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        guard let weekEndDay = cal.date(byAdding: .day, value: 5, to: todayStart),
              let weekEnd = cal.date(bySettingHour: 23, minute: 59, second: 59, of: weekEndDay),
              let weekStart = cal.date(byAdding: .day, value: -1, to: todayStart)
        else {
            return streakDefaultJSONFallback
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let startStr = formatter.string(from: weekStart)
        let endStr = formatter.string(from: weekEnd)

        return """
        {
          "currentStreakWeeks": 4,
          "bestStreakWeeks": 8,
          "weeklyGoal": 3,
          "nextWeeklyGoal": 4,
          "completedThisWeek": 2,
          "remainingToGoal": 1,
          "weekStartDate": "\(startStr)",
          "weekEndDate": "\(endStr)",
          "isGoalCompleted": false,
          "streakFreezeCount": 1,
          "canUseStreakFreeze": true,
          "wasFreezeUsedThisWeek": false
        }
        """
    }

    private static let streakDefaultJSONFallback = """
    {
      "currentStreakWeeks": 4,
      "bestStreakWeeks": 8,
      "weeklyGoal": 3,
      "nextWeeklyGoal": 4,
      "completedThisWeek": 2,
      "remainingToGoal": 1,
      "weekStartDate": "2030-05-01T00:00:00Z",
      "weekEndDate": "2030-05-07T23:59:59Z",
      "isGoalCompleted": false,
      "streakFreezeCount": 1,
      "canUseStreakFreeze": true,
      "wasFreezeUsedThisWeek": false
    }
    """

    private static let streakCompletedJSON = """
    {
      "currentStreakWeeks": 5,
      "bestStreakWeeks": 8,
      "weeklyGoal": 3,
      "nextWeeklyGoal": 3,
      "completedThisWeek": 3,
      "remainingToGoal": 0,
      "weekStartDate": "2026-05-04T00:00:00Z",
      "weekEndDate": "2026-05-10T23:59:59Z",
      "isGoalCompleted": true,
      "streakFreezeCount": 1,
      "canUseStreakFreeze": true,
      "wasFreezeUsedThisWeek": false
    }
    """

    private static let streakFreezeJSON = """
    {
      "currentStreakWeeks": 4,
      "bestStreakWeeks": 8,
      "weeklyGoal": 3,
      "nextWeeklyGoal": 4,
      "completedThisWeek": 2,
      "remainingToGoal": 1,
      "weekStartDate": "2026-05-04T00:00:00Z",
      "weekEndDate": "2026-05-10T23:59:59Z",
      "isGoalCompleted": false,
      "streakFreezeCount": 0,
      "canUseStreakFreeze": false,
      "wasFreezeUsedThisWeek": true
    }
    """

    private static func streakDangerJSON() -> String {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        guard let endDay = cal.date(byAdding: .day, value: 2, to: todayStart) else {
            return Self.streakDefaultJSON()
        }
        let weekEnd = cal.date(bySettingHour: 23, minute: 59, second: 59, of: endDay) ?? endDay

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let startStr = formatter.string(from: todayStart)
        let endStr = formatter.string(from: weekEnd)

        return """
        {
          "currentStreakWeeks": 4,
          "bestStreakWeeks": 8,
          "weeklyGoal": 5,
          "nextWeeklyGoal": 5,
          "completedThisWeek": 1,
          "remainingToGoal": 4,
          "weekStartDate": "\(startStr)",
          "weekEndDate": "\(endStr)",
          "isGoalCompleted": false,
          "streakFreezeCount": 0,
          "canUseStreakFreeze": false,
          "wasFreezeUsedThisWeek": false
        }
        """
    }

    private static let recentUnlocksJSON = """
    [
      {
        "id": "ach_rookie",
        "code": "rookie",
        "name": "Rookie",
        "description": "First recorded workout",
        "iconName": "eyeglasses",
        "category": "workoutMilestones",
        "rarity": "common",
        "status": "unlocked",
        "progressCurrent": 1,
        "progressTarget": 1,
        "unlockedAt": "2026-05-01T10:00:00Z",
        "isSecret": false
      }
    ]
    """

    private static let achievementsJSON = """
    [
      {
        "id": "ach_rookie",
        "code": "rookie",
        "name": "Rookie",
        "description": "First recorded workout",
        "iconName": "eyeglasses",
        "category": "workoutMilestones",
        "rarity": "common",
        "status": "unlocked",
        "progressCurrent": 1,
        "progressTarget": 1,
        "unlockedAt": "2026-05-01T10:00:00Z",
        "isSecret": false
      },
      {
        "id": "ach_50",
        "code": "workouts_50",
        "name": "50 Workouts",
        "description": "Completed 50 workouts",
        "iconName": "tortoise.fill",
        "category": "workoutMilestones",
        "rarity": "rare",
        "status": "locked",
        "progressCurrent": 32,
        "progressTarget": 50,
        "unlockedAt": null,
        "isSecret": false
      },
      {
        "id": "ach_week_warrior",
        "code": "week_warrior",
        "name": "Week Warrior",
        "description": "Stay consistent for four weeks",
        "iconName": "calendar",
        "category": "consistency",
        "rarity": "common",
        "status": "unlocked",
        "progressCurrent": 4,
        "progressTarget": 4,
        "unlockedAt": "2026-05-03T10:00:00Z",
        "isSecret": false
      }
    ]
    """

    private static let leaderboardPreviewJSON = """
    [
      {
        "id": "leader_1",
        "rank": 1,
        "userID": "2",
        "name": "Kylie Stone",
        "username": "kylie_mock",
        "avatarSystemName": "person.crop.circle.fill",
        "currentStreakWeeks": 7,
        "completedWorkouts": 130,
        "isCurrentUser": false,
        "isFollowing": true,
        "isFriend": true
      },
      {
        "id": "leader_2",
        "rank": 2,
        "userID": "1",
        "name": "UI Test User",
        "username": "ui_test",
        "avatarSystemName": "person.circle.fill",
        "currentStreakWeeks": 4,
        "completedWorkouts": 128,
        "isCurrentUser": true,
        "isFollowing": false,
        "isFriend": false
      }
    ]
    """

    private static let myRankJSON = """
    {
      "rank": 2,
      "currentStreakWeeks": 4,
      "completedWorkouts": 128
    }
    """
}
