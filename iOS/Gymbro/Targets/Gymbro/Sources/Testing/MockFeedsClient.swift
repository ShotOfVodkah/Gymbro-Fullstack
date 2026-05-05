import Foundation
import GymbroNetwork
import GymbroTypes

final class MockFeedsClient: FeedsClientProtocol {

    func fetchFeed(scope: FeedScope, limit: Int, cursor: Date?) async throws -> FeedPageResponse {
        FeedPageResponse(
            items: [],
            next_cursor: nil,
            has_more: false
        )
    }

    func fetchCommunities() async throws -> [FeedCommunityItemResponse] { [] }

    func fetchPostComments(postID: String) async throws -> [FeedCommentResponse] { [] }

    func fetchPostsByUser(userID: String) async throws -> [FeedPostItemResponse] { [] }

    func createPostComment(postID: String, text: String) async throws -> FeedCommentResponse {
        MockDecoder.decode("""
        {
          "id": "c1",
          "post_id": "\(postID)",
          "author_id": "1",
          "author_name": "UI User",
          "author_avatar": "person.circle",
          "text": "\(text)",
          "created_at": "2026-05-01T10:00:00Z",
          "likes_count": 0,
          "is_liked": false
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
        MockDecoder.decode("""
        {
          "post_id": "mock",
          "shared_to_feed": true,
          "shared_chat_ids": []
        }
        """)
    }

    func fetchFriends() async throws -> [PersonItemResponse] { [] }
    func fetchFollowing() async throws -> [PersonItemResponse] { [] }
    func fetchDiscoverPeople(query: String?) async throws -> [PersonItemResponse] { [] }

    func fetchPerson(id: String) async throws -> PersonItemResponse {
        MockDecoder.decode("""
        {
          "id": "\(id)",
          "name": "User",
          "username": "user",
          "avatar_system_name": "person.circle",
          "subtitle": "",
          "is_following": false
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
        try await fetchChat(id: "chat_1")
    }

    func createGroupChat(title: String, description: String, participantIDs: [String]) async throws -> ChatRoomResponse {
        try await fetchChat(id: "group_1")
    }

    func fetchChat(id: String) async throws -> ChatRoomResponse {
        MockDecoder.decode("""
        {
          "id": "\(id)",
          "kind": "joined_group",
          "title": "Mock Chat",
          "description": "",
          "participants": []
        }
        """)
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
}
