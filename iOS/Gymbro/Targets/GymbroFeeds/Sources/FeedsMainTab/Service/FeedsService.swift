import Foundation
import GymbroNetwork
import GymbroTypes

protocol FeedsMainTabService {
    func fetchScreen(scope: FeedScope) async throws -> FeedsMainTabScreenData
    func fetchPosts(scope: FeedScope) async throws -> [FeedPost]
    func fetchCommunities() async throws -> [FeedCommunity]
    func fetchPostsPage(scope: FeedScope, limit: Int, cursor: Date?) async throws -> FeedPostsPage
    
    func fetchChatCreationPeople() async throws -> [PersonItem]
    func createDirectChat(with personID: String) async throws -> ChatSessionInput
    func createGroupChat(title: String, participantIDs: [String]) async throws -> ChatSessionInput
    func openExistingChat(communityID: String) async throws -> ChatSessionInput

    func fetchComments(postID: String) async throws -> [FeedComment]
    func createComment(postID: String, text: String) async throws -> FeedComment
    
    func toggleLike(postID: String, isLiked: Bool) async throws
}

struct FeedsMainTabScreenData {
    let communities: [FeedCommunity]
    let posts: [FeedPost]
    let nextCursor: Date?
    let hasMorePosts: Bool
}

struct FeedPostsPage {
    let posts: [FeedPost]
    let nextCursor: Date?
    let hasMore: Bool
}

final class FeedsMainTabServiceImpl: FeedsMainTabService {
    
    init(client: any FeedsClientProtocol, perksEvents: any PerksEventTrackingService) {
        self.client = client
        self.perksEvents = perksEvents
    }
    
    func fetchScreen(scope: FeedScope = .all) async throws -> FeedsMainTabScreenData {
        async let postsPage = fetchPostsPage(scope: scope, limit: 20, cursor: nil)
        async let communities = fetchCommunities()

        let resolvedPostsPage = try await postsPage
        
        return try await FeedsMainTabScreenData(
            communities: communities,
            posts: resolvedPostsPage.posts,
            nextCursor: resolvedPostsPage.nextCursor,
            hasMorePosts: resolvedPostsPage.hasMore
        )
    }
    
    func fetchPosts(scope: FeedScope = .all) async throws -> [FeedPost] {
        try await fetchPostsPage(scope: scope, limit: 20, cursor: nil).posts
    }
    
    func fetchPostsPage(scope: FeedScope = .all, limit: Int = 20, cursor: Date? = nil) async throws -> FeedPostsPage {
        let page = try await client.fetchFeed(scope: scope, limit: limit, cursor: cursor)
        
        return FeedPostsPage(
            posts: page.items.map(FeedPost.init(response:)),
            nextCursor: page.next_cursor,
            hasMore: page.has_more
        )
    }

    func fetchCommunities() async throws -> [FeedCommunity] {
        let response = try await client.fetchCommunities()
        return response.map(FeedCommunity.init(response:))
    }
    
    func fetchChatCreationPeople() async throws -> [PersonItem] {
        async let friendsResponse = client.fetchFriends()
        async let followingResponse = client.fetchFollowing()
        async let discoverResponse = client.fetchDiscoverPeople(query: nil)
        
        let friends = try await friendsResponse.map(PersonItem.init(response:))
        let following = try await followingResponse.map(PersonItem.init(response:))
        let discover = try await discoverResponse.map(PersonItem.init(response:))
        
        return uniquePeople(friends + following + discover)
    }
    
    func createDirectChat(with personID: String) async throws -> ChatSessionInput {
        let room = try await client.createDirectChat(participantID: personID)
        return ChatSessionInput(response: room)
    }
    
    func createGroupChat(title: String, participantIDs: [String]) async throws -> ChatSessionInput {
        let room = try await client.createGroupChat(
            title: title,
            description: "",
            participantIDs: participantIDs
        )
        return ChatSessionInput(response: room)
    }
    
    func openExistingChat(communityID: String) async throws -> ChatSessionInput {
        let room = try await client.fetchChat(id: communityID)
        return ChatSessionInput(response: room)
    }
    
    func fetchComments(postID: String) async throws -> [FeedComment] {
        let response = try await client.fetchPostComments(postID: postID)
        return response.map(FeedComment.init(response:))
    }
    
    func createComment(postID: String, text: String) async throws -> FeedComment {
        let response = try await client.createPostComment(postID: postID, text: text)
        await perksEvents.trackFriendWorkoutCommented()
        return FeedComment(response: response)
    }
    
    private let client: any FeedsClientProtocol
    private let perksEvents: any PerksEventTrackingService
    
    private func uniquePeople(_ people: [PersonItem]) -> [PersonItem] {
        var seen = Set<String>()
        var result: [PersonItem] = []
        
        for person in people {
            if seen.contains(person.id) { continue }
            seen.insert(person.id)
            result.append(person)
        }
        
        return result
    }
    
    func toggleLike(postID: String, isLiked: Bool) async throws {
        if isLiked {
            try await client.unlikePost(postID: postID)
        } else {
            try await client.likePost(postID: postID)
        }
    }
}
