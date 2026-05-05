import Foundation
import GymbroNetwork
import GymbroTypes

final class MockProfileClient: ProfileClientProtocol {

    func fetchMyProfileForEdit() async throws -> EditProfileResponse {
        try MockDecoder.decode("""
        {
          "user_id": 1,
          "name": "UI Test User",
          "username": "ui_test",
          "status": "Ready to lift",
          "subtitle": "Athlete • GymBro",
          "bio": "Stable mock profile for UI tests.",
          "avatar_system_name": "person.circle.fill"
        }
        """)
    }

    func updateMyProfile(_ request: UpdateProfileRequest) async throws -> EditProfileResponse {
        try MockDecoder.decode("""
        {
          "user_id": 1,
          "name": "UI Test User",
          "username": "ui_test",
          "status": "Ready to lift",
          "subtitle": "Athlete • GymBro",
          "bio": "Updated by mock client.",
          "avatar_system_name": "person.circle.fill"
        }
        """)
    }

    func fetchMyStatistics() async throws -> ProfileStatisticsResponse {
        try MockDecoder.decode(statisticsJSON(userID: 1))
    }

    func fetchStatistics(userID: Int) async throws -> ProfileStatisticsResponse {
        try MockDecoder.decode(statisticsJSON(userID: userID))
    }

    func fetchMySettings() async throws -> ProfileSettingsResponse {
        try MockDecoder.decode("""
        {
          "push_notifications_enabled": true,
          "workout_reminders": true,
          "private_account": false,
          "show_activity": true,
          "discover_visibility": true
        }
        """)
    }

    func updateMySettings(_ request: UpdateProfileSettingsRequest) async throws -> ProfileSettingsResponse {
        try await fetchMySettings()
    }

    func fetchMyMainProfile() async throws -> ProfileMainResponse {
        ProfileMainResponse(
            user_id: 1,
            name: "UI Test User",
            username: "ui_test",
            status: "Ready to lift",
            subtitle: "Athlete • GymBro",
            bio: "Stable mock profile for UI tests.",
            avatar_system_name: "person.circle.fill",
            badge: "Consistency",
            is_following: nil,
            workouts_this_month: 14,
            total_workouts: 128,
            total_hours: 96,
            favorite_workout_type: "Strength",
            most_active_weekday: "Monday",
            consistency_percent: 82,
            weekly_activity: []
        )
    }

    func fetchMainProfile(userID: Int) async throws -> ProfileMainResponse {
        ProfileMainResponse(
            user_id: userID,
            name: "Kylie Stone",
            username: "kylie_mock",
            status: "Consistency over intensity",
            subtitle: "Athlete • GymBro",
            bio: "Mock external profile.",
            avatar_system_name: "person.crop.circle.fill",
            badge: "Power",
            is_following: false,
            workouts_this_month: 9,
            total_workouts: 72,
            total_hours: 54,
            favorite_workout_type: "Strength",
            most_active_weekday: "Wednesday",
            consistency_percent: 76,
            weekly_activity: []
        )
    }

    private func statisticsJSON(userID: Int) -> String {
        """
        {
          "user_id": \(userID),
          "summary": {
            "total_workouts": 128,
            "total_duration_hours": 96,
            "consistency": 82,
            "workouts_this_week": 4,
            "workouts_this_month": 14
          },
          "favorite_categories": [],
          "weekly_activity": [],
          "monthly_progress": []
        }
        """
    }
}
