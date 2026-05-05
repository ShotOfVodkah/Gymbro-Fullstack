import Foundation
import GymbroTypes

public final class FeedsClient {
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    let client: NetworkClient
    
    func requireUserId() throws -> String {
        guard let userId = AppMicroservices.tokens.userId, !userId.isEmpty else {
            throw NetworkError.unauthorized
        }
        return userId
    }
}

extension FeedsClient: FeedsClientProtocol {}
