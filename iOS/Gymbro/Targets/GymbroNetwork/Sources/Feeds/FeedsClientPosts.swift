import Foundation
import GymbroTypes

public extension FeedsClient {
    
    func fetchFeed() async throws -> [FeedPostItemResponse] {
        let _ = try requireUserId()
        
        return try await client.request(
            method: .GET,
            path: "feed",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [FeedPostItemResponse].self
        )
    }
    
    func fetchCommunities() async throws -> [FeedCommunityItemResponse] {
        try await client.request(
            method: .GET,
            path: "communities",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [FeedCommunityItemResponse].self
        )
    }
    
    func fetchPostComments(postID: String) async throws -> [FeedCommentResponse] {
        try await client.request(
            method: .GET,
            path: "posts/\(postID)/comments",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [FeedCommentResponse].self
        )
    }
    
    func fetchPostsByUser(userID: String) async throws -> [FeedPostItemResponse] {
        try await client.request(
            method: .GET,
            path: "feed/users/\(userID)/posts",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [FeedPostItemResponse].self
        )
    }

    func createPostComment(postID: String, text: String) async throws -> FeedCommentResponse {
        try await client.request(
            method: .POST,
            path: "posts/\(postID)/comments",
            body: CreateFeedCommentRequest(text: text),
            requiresAuth: true,
            responseType: FeedCommentResponse.self
        )
    }
    
    func likePost(postID: String) async throws {
        try await client.requestVoid(
            method: .POST,
            path: "posts/\(postID)/like",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }

    func unlikePost(postID: String) async throws {
        try await client.requestVoid(
            method: .DELETE,
            path: "posts/\(postID)/like",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }
    
    func shareWorkout(
        sessionID: String,
        publishToFeed: Bool,
        existingChatIDs: [String],
        directUserIDs: [String],
        description: String,
        location: String?
    ) async throws -> ShareWorkoutResponse {
        try await client.request(
            method: .POST,
            path: "shares/workout",
            body: ShareWorkoutRequest(
                session_id: sessionID,
                publish_to_feed: publishToFeed,
                existing_chat_ids: existingChatIDs,
                direct_user_ids: directUserIDs,
                description: description,
                location: location
            ),
            requiresAuth: true,
            responseType: ShareWorkoutResponse.self
        )
    }
}
