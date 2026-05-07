import Foundation
import GymbroTypes
import GymbroNetwork

public protocol ProfileGateway {
    func fetchMainProfile(mode: ProfileViewMode) async throws -> ProfileMainResponse
    func createDirectChat(with personID: String) async throws -> ChatSessionInput
    func toggleFollow(userID: Int, isFollowing: Bool) async throws
}

public final class ProfileGatewayImpl: ProfileGateway {
    
    public init(
        profileClient: any ProfileClientProtocol,
        feedsClient: any FeedsClientProtocol
    ) {
        self.profileClient = profileClient
        self.feedsClient = feedsClient
    }
    
    public func fetchMainProfile(mode: ProfileViewMode) async throws -> ProfileMainResponse {
        switch mode {
        case .myProfile:
            return try await profileClient.fetchMyMainProfile()
            
        case .otherUserProfile(let userID):
            return try await profileClient.fetchMainProfile(userID: userID)
        }
    }
    
    public func createDirectChat(with personID: String) async throws -> ChatSessionInput {
        let room = try await feedsClient.createDirectChat(participantID: personID)
        return ChatSessionInput(response: room)
    }
    
    public func toggleFollow(userID: Int, isFollowing: Bool) async throws {
        let personID = String(userID)
        
        if isFollowing {
            try await feedsClient.unfollowPerson(id: personID)
        } else {
            try await feedsClient.followPerson(id: personID)
        }
    }
    
    private let profileClient: any ProfileClientProtocol
    private let feedsClient: any FeedsClientProtocol
}
