import Foundation
import GymbroNetwork
import GymbroTypes

final class MockPerksClient: PerksClient {

    func fetchDashboard() async throws -> PerksDashboardResponse {
        try MockDecoder.decode("""
        {
          "streak": {
            "currentStreakWeeks": 4,
            "bestStreakWeeks": 8,
            "weeklyGoal": 3,
            "nextWeeklyGoal": 4,
            "completedThisWeek": 2,
            "remainingToGoal": 1,
            "weekStartDate": "2026-05-04T00:00:00Z",
            "weekEndDate": "2026-05-10T23:59:59Z",
            "isGoalCompleted": false,
            "streakFreezeCount": 1,
            "canUseStreakFreeze": true,
            "wasFreezeUsedThisWeek": false
          },
          "recentUnlocks": [
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
          ],
          "achievements": [
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
            }
          ],
          "leaderboardPreview": [
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
          ],
          "myRank": {
            "rank": 2,
            "currentStreakWeeks": 4,
            "completedWorkouts": 128
          }
        }
        """)
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
}
