import Foundation
import GymbroTypes

public protocol FeedsClientProtocol {
    func fetchFeed(scope: FeedScope, limit: Int, cursor: Date?) async throws -> FeedPageResponse
    func fetchCommunities() async throws -> [FeedCommunityItemResponse]
    func fetchPostComments(postID: String) async throws -> [FeedCommentResponse]
    func fetchPostsByUser(userID: String) async throws -> [FeedPostItemResponse]
    func createPostComment(postID: String, text: String) async throws -> FeedCommentResponse
    func likePost(postID: String) async throws
    func unlikePost(postID: String) async throws

    func shareWorkout(
        sessionID: String,
        publishToFeed: Bool,
        existingChatIDs: [String],
        directUserIDs: [String],
        description: String,
        location: String?
    ) async throws -> ShareWorkoutResponse

    func fetchFriends() async throws -> [PersonItemResponse]
    func fetchFollowing() async throws -> [PersonItemResponse]
    func fetchDiscoverPeople(query: String?) async throws -> [PersonItemResponse]
    func fetchPerson(id: String) async throws -> PersonItemResponse
    func followPerson(id: String) async throws
    func unfollowPerson(id: String) async throws
    func fetchFriendsByUser(userID: String) async throws -> [PersonItemResponse]
    func fetchFollowingByUser(userID: String) async throws -> [PersonItemResponse]

    func fetchCalendarPeople(context: CalendarContext) async throws -> [CalendarPersonResponse]

    func fetchCalendarMonth(
        context: CalendarContext,
        month: Date,
        selectedPersonID: String?
    ) async throws -> CalendarMonthResponse

    func createDirectChat(participantID: String) async throws -> ChatRoomResponse

    func createGroupChat(
        title: String,
        description: String,
        participantIDs: [String]
    ) async throws -> ChatRoomResponse

    func fetchChat(id: String) async throws -> ChatRoomResponse
    func fetchChatMessages(id: String) async throws -> [ChatMessageResponse]
    func sendTextMessage(chatID: String, text: String) async throws -> ChatMessageResponse
    func sendWorkoutMessage(chatID: String, sessionID: String?) async throws -> ChatMessageResponse
    func toggleMessageReaction(messageID: String, emoji: String) async throws -> [ChatReactionResponse]

    func updateGroupChat(
        chatID: String,
        title: String,
        description: String
    ) async throws -> ChatRoomResponse

    func addPeopleToGroup(chatID: String, userIDs: [String]) async throws -> ChatRoomResponse
    func removePersonFromGroup(chatID: String, userID: String) async throws -> ChatRoomResponse
    func deleteGroupChat(chatID: String) async throws

    func markChatRead(
        chatID: String,
        lastReadMessageID: String?
    ) async throws -> ChatReadResponse

    func startTyping(chatID: String) async throws
    func stopTyping(chatID: String) async throws
}
