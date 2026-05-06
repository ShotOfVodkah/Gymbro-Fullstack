import Foundation
import GymbroNetwork
import GymbroTypes

final class MockFeedsClient: FeedsClientProtocol {

    func fetchFeed(scope: FeedScope, limit: Int, cursor: Date?) async throws -> FeedPageResponse {
        FeedPageResponse(
            items: [Self.uiTestFeedPost],
            next_cursor: nil,
            has_more: false
        )
    }

    func fetchCommunities() async throws -> [FeedCommunityItemResponse] {
        Self.uiTestCommunities
    }

    func fetchPostComments(postID: String) async throws -> [FeedCommentResponse] {
        guard postID == Self.uiTestPostServerID else { return [] }
        return Self.uiTestComments
    }

    func fetchPostsByUser(userID: String) async throws -> [FeedPostItemResponse] { [] }

    func createPostComment(postID: String, text: String) async throws -> FeedCommentResponse {
        let escaped = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return MockDecoder.decode("""
        {
          "id": "c_new",
          "author": {
            "id": "1",
            "name": "UI User",
            "avatar_url": "person.circle.fill"
          },
          "text": "\(escaped)",
          "created_at": "2026-05-06T12:00:00Z"
        }
        """)
    }

    func likePost(postID: String) async throws {}
    func unlikePost(postID: String) async throws {}

    func shareWorkout(
        sessionID: String,
        publishToFeed: Bool,
        existingChatIDs: [String],
        directUserIDs: [String],
        description: String,
        location: String?
    ) async throws -> ShareWorkoutResponse {
        let createdPostJSON = publishToFeed ? "\"mock_feed_post\"" : "null"
        let deliveredIDsJSON = existingChatIDs.map { "\"\($0)\"" }.joined(separator: ",")
        return MockDecoder.decode("""
        {
          "created_post_id": \(createdPostJSON),
          "delivered_chat_ids": [\(deliveredIDsJSON)],
          "created_chat_ids": []
        }
        """)
    }

    func fetchFriends() async throws -> [PersonItemResponse] { MockFeedsClient.uiTestFriendsSample }

    func fetchFollowing() async throws -> [PersonItemResponse] { [] }

    func fetchDiscoverPeople(query: String?) async throws -> [PersonItemResponse] { [] }

    func fetchPerson(id: String) async throws -> PersonItemResponse {
        MockDecoder.decode("""
        {
          "id": "\(id)",
          "name": "Kylie Stone",
          "username": "kylie_mock",
          "status": "Training",
          "subtitle": "",
          "avatar_system_name": "person.crop.circle.fill",
          "is_following": false,
          "is_current_friend": true,
          "badge": null,
          "workouts_this_month": 9
        }
        """)
    }

    func followPerson(id: String) async throws {}
    func unfollowPerson(id: String) async throws {}

    func fetchFriendsByUser(userID: String) async throws -> [PersonItemResponse] { [] }
    func fetchFollowingByUser(userID: String) async throws -> [PersonItemResponse] { [] }

    func fetchCalendarPeople(context: CalendarContext) async throws -> [CalendarPersonResponse] { [] }

    func fetchCalendarMonth(
        context: CalendarContext,
        month: Date,
        selectedPersonID: String?
    ) async throws -> CalendarMonthResponse {
        CalendarMonthResponse(
            month: "2026-05",
            my_workouts: [],
            partner_workouts: []
        )
    }

    func createDirectChat(participantID: String) async throws -> ChatRoomResponse {
        MockDecoder.decode("""
        {
          "id": "chat_created_\(participantID)",
          "kind": "direct",
          "title": "Direct chat",
          "description": "",
          "participants": [
            {"id": "\(participantID)", "name": "Friend", "avatar_system_name": "person.circle.fill"}
          ]
        }
        """)
    }

    func createGroupChat(title: String, description: String, participantIDs: [String]) async throws -> ChatRoomResponse {
        MockDecoder.decode("""
        {
          "id": "group_created",
          "kind": "joined_group",
          "title": "\(title)",
          "description": "\(description)",
          "participants": []
        }
        """)
    }

    func fetchChat(id: String) async throws -> ChatRoomResponse {
        switch id {
        case Self.uiTestDirectCommunityID:
            return MockDecoder.decode(Self.directChatRoomJSON)
        case Self.uiTestGroupCommunityID:
            return MockDecoder.decode(Self.groupChatRoomJSON)
        default:
            return MockDecoder.decode("""
            {
              "id": "\(id)",
              "kind": "joined_group",
              "title": "Mock Chat",
              "description": "",
              "participants": []
            }
            """)
        }
    }

    func fetchChatMessages(id: String) async throws -> [ChatMessageResponse] { [] }

    func sendTextMessage(chatID: String, text: String) async throws -> ChatMessageResponse {
        ChatMessageResponse(
            id: UUID().uuidString,
            sender_id: "1",
            sender_name: "UI User",
            sender_avatar_system_name: "person.circle",
            sent_at: Date(),
            is_mine: true,
            kind: "text",
            text: text,
            workout: nil,
            challenge_id: nil,
            reactions: []
        )
    }

    func sendWorkoutMessage(chatID: String, sessionID: String?) async throws -> ChatMessageResponse {
        try await sendTextMessage(chatID: chatID, text: "Workout")
    }

    func toggleMessageReaction(messageID: String, emoji: String) async throws -> [ChatReactionResponse] { [] }

    func updateGroupChat(chatID: String, title: String, description: String) async throws -> ChatRoomResponse {
        try await fetchChat(id: chatID)
    }

    func addPeopleToGroup(chatID: String, userIDs: [String]) async throws -> ChatRoomResponse {
        try await fetchChat(id: chatID)
    }

    func removePersonFromGroup(chatID: String, userID: String) async throws -> ChatRoomResponse {
        try await fetchChat(id: chatID)
    }

    func deleteGroupChat(chatID: String) async throws {}

    func markChatRead(chatID: String, lastReadMessageID: String?) async throws -> ChatReadResponse {
        ChatReadResponse(
            community_id: chatID,
            user_id: "1",
            last_read_message_id: lastReadMessageID,
            last_read_at: Date()
        )
    }

    func startTyping(chatID: String) async throws {}
    func stopTyping(chatID: String) async throws {}

    // MARK: - UITest fixtures

    static let uiTestPostServerID = "feed_post_ui_1"
    static let uiTestDirectCommunityID = "chat_direct_ui"
    static let uiTestGroupCommunityID = "chat_group_ui"

    private static let uiTestFriendsSample: [PersonItemResponse] = [
        MockDecoder.decode("""
        {
          "id": "77",
          "name": "Friend One",
          "username": "friend_one",
          "status": "Online",
          "subtitle": "",
          "avatar_system_name": "person.circle.fill",
          "is_following": true,
          "is_current_friend": true,
          "badge": null,
          "workouts_this_month": 5
        }
        """)
    ]

    private static let uiTestFeedPost: FeedPostItemResponse = MockDecoder.decode(feedPostJSON)

    private static let uiTestCommunities: [FeedCommunityItemResponse] = [
        FeedCommunityItemResponse(
            id: uiTestDirectCommunityID,
            title: "Alex Partner",
            display_title: "Alex Partner",
            kind: "direct",
            icon: "person.fill",
            is_system_image: true,
            members_count: 2,
            unread_count: 0,
            last_message_preview: "Hey!",
            last_message_at: Date(timeIntervalSince1970: 1_717_000_000)
        ),
        FeedCommunityItemResponse(
            id: uiTestGroupCommunityID,
            title: "Gym Crew",
            display_title: "Gym Crew",
            kind: "joined_group",
            icon: "person.3.fill",
            is_system_image: true,
            members_count: 5,
            unread_count: 0,
            last_message_preview: nil,
            last_message_at: nil
        )
    ]

    private static let uiTestComments: [FeedCommentResponse] = [
        MockDecoder.decode("""
        {
          "id": "cm1",
          "author": {"id": "5", "name": "Sam", "avatar_url": "person.circle.fill"},
          "text": "Nice work!",
          "created_at": "2026-05-05T11:00:00Z"
        }
        """)
    ]

    private static let feedPostJSON = """
    {
      "id": "feed_post_ui_1",
      "author": {
        "id": "42",
        "name": "Kylie Stone",
        "avatar_url": "person.crop.circle.fill"
      },
      "community": null,
      "workout": {
        "id": "session_ui_test_1",
        "title": "Morning Strength",
        "category": "strength",
        "duration_minutes": 45,
        "exercise_count": 3,
        "exercises_preview": [
          {
            "id": "ex_ui_1",
            "name": "Bench Press",
            "type": "strength",
            "muscleGroup": "chest",
            "sets": 3,
            "reps": 10,
            "weightKg": 60,
            "durationMinutes": null,
            "pace": null,
            "holdSeconds": null,
            "breathCount": null
          },
          {
            "id": "ex_ui_2",
            "name": "Squat",
            "type": "strength",
            "muscleGroup": "legs",
            "sets": 4,
            "reps": 8,
            "weightKg": 80,
            "durationMinutes": null,
            "pace": null,
            "holdSeconds": null,
            "breathCount": null
          }
        ]
      },
      "description": "Great session!",
      "location": "Test Gym",
      "created_at": "2026-05-05T10:00:00Z",
      "likes_count": 3,
      "comments_count": 2,
      "is_liked": false,
      "kind": "friend",
      "is_from_following": true,
      "is_from_direct_chat": false,
      "is_from_group_community": false
    }
    """

    private static let directChatRoomJSON = """
    {
      "id": "chat_direct_ui",
      "kind": "direct",
      "title": "Alex Partner",
      "description": "",
      "participants": [
        {"id": "42", "name": "Alex Partner", "avatar_system_name": "person.circle.fill"}
      ]
    }
    """

    private static let groupChatRoomJSON = """
    {
      "id": "chat_group_ui",
      "kind": "joined_group",
      "title": "Gym Crew",
      "description": "",
      "participants": []
    }
    """
}
