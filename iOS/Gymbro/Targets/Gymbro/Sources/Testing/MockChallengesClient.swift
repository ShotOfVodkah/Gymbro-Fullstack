import Foundation
import GymbroNetwork
import GymbroTypes

final class MockChallengesClient: ChallengesClient {

    private var challengesLeftIDs: Set<String> = []
    private var joinedChallengeChatIDs: [String: String] = [:]

    private var unavailableTeamsUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("-uitest-challenges-unavailable-teams")
    }

    func fetchChallenges() async throws -> ChallengesListResponse {
        let base: ChallengesListResponse = MockDecoder.decode("""
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
              "unit": "minutes",
              "team": {
                "team_id": "team_cardio_mock",
                "chat_id": "mock_group_chat_cardio",
                "team_name": "Morning Run Club"
              }
            }
          ]
        }
        """)
        let mapped = base.challenges.map { challenge -> ChallengeResponse in
            if challenge.id == "challenge_power_sprint", joinedChallengeChatIDs[challenge.id] != nil {
                let chatID = joinedChallengeChatIDs[challenge.id]!
                return challenge.replacing(
                    participationStatus: "in_progress",
                    team: ChallengeTeamPreviewResponse(
                        teamID: "mock_team",
                        chatID: chatID,
                        teamName: "GymBro Squad"
                    )
                )
            }
            if challenge.id == "challenge_cardio_week", challengesLeftIDs.contains(challenge.id) {
                return challenge.replacing(participationStatus: "not_joined", team: nil)
            }
            return challenge
        }
        return ChallengesListResponse(challenges: mapped)
    }

    func fetchChallengeDetails(id: String) async throws -> ChallengeDetailsResponse {
        if challengesLeftIDs.contains(id) {
            if id == "challenge_cardio_week" {
                return MockDecoder.decode(cardioWeekDetailsLeftJSON)
            }
        }
        if id == "challenge_power_sprint", joinedChallengeChatIDs[id] != nil {
            let chatID = joinedChallengeChatIDs[id]!
            return MockDecoder.decode(powerSprintJoinedDetailsJSON(chatID: chatID))
        }
        if id == "challenge_cardio_week" {
            return MockDecoder.decode(cardioWeekJoinedDetailsJSON)
        }
        return MockDecoder.decode(powerSprintNotJoinedDetailsJSON(id: id))
    }

    func fetchAvailableTeams(challengeID: String) async throws -> AvailableChallengeTeamsResponse {
        if unavailableTeamsUITest {
            return MockDecoder.decode("""
            {
              "teams": [
                {
                  "chat_id": "mock_group_chat",
                  "chat_name": "GymBro Squad",
                  "avatar_system_name": "person.3.fill",
                  "members_count": 4,
                  "can_join": false,
                  "reason": "Team is full"
                }
              ]
            }
            """)
        }

        return MockDecoder.decode("""
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
        joinedChallengeChatIDs[challengeID] = chatID
        return MockDecoder.decode("""
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
        challengesLeftIDs.insert(challengeID)
        joinedChallengeChatIDs.removeValue(forKey: challengeID)
        return MockDecoder.decode("""
        {
          "status": "left"
        }
        """)
    }

    func fetchLeaderboard(challengeID: String) async throws -> ChallengeLeaderboardResponse {
        MockDecoder.decode("""
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
        MockDecoder.decode("""
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

    private var cardioWeekJoinedDetailsJSON: String {
        """
        {
          "id": "challenge_cardio_week",
          "title": "Cardio Week",
          "description": "Collect 300 training minutes with your team.",
          "rules": [
            "Only logged training minutes count.",
            "Progress is shared across your challenge team."
          ],
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
          "unit": "minutes",
          "team": {
            "team_id": "team_cardio_mock",
            "challenge_id": "challenge_cardio_week",
            "chat_id": "mock_group_chat_cardio",
            "team_name": "Morning Run Club",
            "team_avatar": "figure.run",
            "members_count": 6,
            "current_value": 120,
            "target_value": 300,
            "progress_percent": 40,
            "status": "in_progress",
            "joined_at": "2026-05-04T10:00:00Z"
          },
          "participants": [],
          "rewards": null,
          "target_filter": null
        }
        """
    }

    private var cardioWeekDetailsLeftJSON: String {
        """
        {
          "id": "challenge_cardio_week",
          "title": "Cardio Week",
          "description": "Collect 300 training minutes with your team.",
          "rules": [
            "Only logged training minutes count.",
            "Progress is shared across your challenge team."
          ],
          "type": "team_training_minutes",
          "status": "active",
          "participation_status": "not_joined",
          "difficulty": "easy",
          "cover_icon": "heart.fill",
          "accent_color": "#22C55E",
          "start_date": "2026-05-04T00:00:00Z",
          "end_date": "2026-05-10T23:59:59Z",
          "target_value": 300,
          "current_value": 120,
          "progress_percent": 40,
          "unit": "minutes",
          "team": null,
          "participants": [],
          "rewards": null,
          "target_filter": null
        }
        """
    }

    private func powerSprintNotJoinedDetailsJSON(id: String) -> String {
        """
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
        """
    }

    private func powerSprintJoinedDetailsJSON(chatID: String) -> String {
        """
        {
          "id": "challenge_power_sprint",
          "title": "Team Power Sprint",
          "description": "Complete 40 workouts as a team before the end of the month.",
          "rules": [
            "Only completed workouts count.",
            "Progress is shared across the selected group chat."
          ],
          "type": "team_workouts_count",
          "status": "active",
          "participation_status": "in_progress",
          "difficulty": "medium",
          "cover_icon": "flame.fill",
          "accent_color": "#A855F7",
          "start_date": "2026-05-01T00:00:00Z",
          "end_date": "2026-05-31T23:59:59Z",
          "target_value": 40,
          "current_value": 18,
          "progress_percent": 45,
          "unit": "workouts",
          "team": {
            "team_id": "mock_team",
            "challenge_id": "challenge_power_sprint",
            "chat_id": "\(chatID)",
            "team_name": "GymBro Squad",
            "team_avatar": "person.3.fill",
            "members_count": 4,
            "current_value": 18,
            "target_value": 40,
            "progress_percent": 45,
            "status": "in_progress",
            "joined_at": "2026-05-05T12:00:00Z"
          },
          "participants": [],
          "rewards": null,
          "target_filter": null
        }
        """
    }
}
