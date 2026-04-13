import Foundation
import GymbroNetwork
import GymbroTypes

protocol FeedsMainTabService {
    func fetchScreen() async throws -> FeedsMainTabScreenData
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
}

final class FeedsMainTabServiceImpl: FeedsMainTabService {
    
    init(client: FeedsClient) {
        self.client = client
    }
    
    func fetchScreen() async throws -> FeedsMainTabScreenData {
        async let feedResponse = client.fetchFeed()
        async let communitiesResponse = client.fetchCommunities()
        
        let posts = try await feedResponse.map(FeedPost.init(response:))
        let communities = try await communitiesResponse.map(FeedCommunity.init(response:))
        
        return FeedsMainTabScreenData(
            communities: communities,
            posts: posts
        )
    }
    
    func fetchChatCreationPeople() async throws -> [PersonItem] {
        async let friendsResponse = client.fetchFriends()
        async let followingResponse = client.fetchFollowing()
        async let discoverResponse = client.fetchDiscoverPeople()
        
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
        return FeedComment(response: response)
    }
    
    private let client: FeedsClient
    
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
