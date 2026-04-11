import Foundation
import GymbroTypes

public final class FeedsClient {
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    private let client: NetworkClient
    
    public func fetchFeed() async throws -> [FeedPostItemResponse] {
        let _ = try requireUserId()
        
        return try await client.request(
            method: .GET,
            path: "feed",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [FeedPostItemResponse].self
        )
    }
    
    private func requireUserId() throws -> String {
        guard let userId = AppMicroservices.tokens.userId, !userId.isEmpty else {
            throw NetworkError.unauthorized
        }
        return userId
    }
}
