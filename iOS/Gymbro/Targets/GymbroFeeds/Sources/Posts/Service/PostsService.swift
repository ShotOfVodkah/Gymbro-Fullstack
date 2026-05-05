import Foundation
import GymbroNetwork
import GymbroTypes

protocol FeedsProfilePostsService {
    func fetchPosts(input: PostsScreenInput) async throws -> [FeedPost]
}

final class FeedsProfilePostsServiceImpl: FeedsProfilePostsService {
    
    init(client: any FeedsClientProtocol) {
        self.client = client
    }
    
    func fetchPosts(input: PostsScreenInput) async throws -> [FeedPost] {
        let response = try await client.fetchPostsByUser(userID: String(input.userID))
        return response.map(FeedPost.init(response:))
    }
    
    private let client: any FeedsClientProtocol
}
