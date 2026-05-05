import Foundation
import GymbroNetwork
import GymbroTypes

final class MockChallengesClient: ChallengesClient {

    func fetchChallenges() async throws -> ChallengesListResponse {
        try MockDecoder.decode("""
        {
          "challenges": [
            {
              "id": "challenge_power_sprint",
              "title": "Team Power Sprint",
              "description": "Complete 40 workouts as a team.",
              "type": "team_workouts_count",
              "status": "active",
              "participation_status": "not_joined",
              "difficulty": "medium",
              "cover_icon": "flame.fill",
              "accent_color": "#A855F7",
              "start_date": "2026-05-01T00:00:00Z",
              "end_date": "2026-05-31T23:59:59Z",
              "target_value": 40,
              "current_value": 18,
              "progress_percent": 45,
              "unit": "workouts"
            },
            {
              "id": "challenge_cardio_week",
              "title": "Cardio Week",
              "description": "Collect 300 training minutes.",
              "type": "team_training_minutes",
              "status": "active",
              "participation_status": "in_progress",
              "difficulty": "easy",
              "cover_icon": "heart.fill",
              "accent_color": "#22C55E",
              "start_date": "2026-05-04T00:00:00Z",
              "end_date": "2026-05-10T23:59:59Z",
              "target_value": 300,
              "current_value": 120,
              "progress_percent": 40,
              "unit": "minutes"
            }
          ]
        }
        """)
    }

    func fetchChallengeDetails(id: String) async throws -> ChallengeDetailsResponse {
        try MockDecoder.decode("""
        {
          "id": "\(id)",
          "title": "Team Power Sprint",
          "description": "Complete 40 workouts as a team before the end of the month.",
          "rules": [
            "Only completed workouts count.",
            "Progress is shared across the selected group chat."
          ],
          "type": "team_workouts_count",
          "status": "active",
          "participation_status": "not_joined",
          "difficulty": "medium",
          "cover_icon": "flame.fill",
          "accent_color": "#A855F7",
          "start_date": "2026-05-01T00:00:00Z",
          "end_date": "2026-05-31T23:59:59Z",
          "target_value": 40,
          "current_value": 18,
          "progress_percent": 45,
          "unit": "workouts",
          "team": null,
          "participants": [],
          "rewards": null,
          "target_filter": null
        }
        """)
    }

    func fetchAvailableTeams(challengeID: String) async throws -> AvailableChallengeTeamsResponse {
        try MockDecoder.decode("""
        {
          "teams": [
            {
              "chat_id": "mock_group_chat",
              "chat_name": "GymBro Squad",
              "avatar_system_name": "person.3.fill",
              "members_count": 4,
              "can_join": true,
              "reason": null
            }
          ]
        }
        """)
    }

    func joinChallenge(challengeID: String, chatID: String) async throws -> JoinChallengeResponse {
        try MockDecoder.decode("""
        {
          "team_id": "mock_team",
          "challenge_id": "\(challengeID)",
          "chat_id": "\(chatID)",
          "team_name": "GymBro Squad",
          "status": "joined",
          "current_value": 18,
          "target_value": 40,
          "progress_percent": 45
        }
        """)
    }

    func leaveChallenge(challengeID: String, teamID: String) async throws -> LeaveChallengeResponse {
        try MockDecoder.decode("""
        {
          "status": "left"
        }
        """)
    }

    func fetchLeaderboard(challengeID: String) async throws -> ChallengeLeaderboardResponse {
        try MockDecoder.decode("""
        {
          "challenge_id": "\(challengeID)",
          "leaderboard": [
            {
              "team_id": "team_1",
              "chat_id": "mock_group_chat",
              "team_name": "GymBro Squad",
              "rank": 1,
              "team_avatar": null,
              "members_count": 4,
              "current_value": 18,
              "target_value": 40,
              "progress_percent": 45,
              "status": "active",
              "is_current_user_team": true
            },
            {
              "team_id": "team_2",
              "chat_id": "mock_group_chat_2",
              "team_name": "Cardio Crew",
              "rank": 2,
              "team_avatar": null,
              "members_count": 3,
              "current_value": 12,
              "target_value": 40,
              "progress_percent": 30,
              "status": "active",
              "is_current_user_team": false
            }
          ]
        }
        """)
    }

    func fetchActivity(challengeID: String) async throws -> [ChallengeActivityResponse] {
        try MockDecoder.decode("""
        [
          {
            "id": "activity_1",
            "user_id": 1,
            "user_name": "UI Test User",
            "avatar_system_name": "person.circle.fill",
            "action": "workout_completed",
            "value": 1,
            "unit": "workouts",
            "source_id": null,
            "created_at": "2026-05-05T10:00:00Z"
          }
        ]
        """)
    }
}
