import Foundation
import GymbroNetwork
import GymbroTypes

protocol ProfileMainTabService {
    func fetchScreen(mode: ProfileViewMode) async throws -> ProfileMainScreenModel
    func createDirectChat(with personID: String) async throws -> ChatSessionInput
    func toggleFollow(for userID: Int, isFollowing: Bool) async throws
}

final class ProfileMainServiceImpl: ProfileMainTabService {
    
    private let client: FeedsClient // change
    
    init(client: FeedsClient) {
        self.client = client
    }
    
    func fetchScreen(mode: ProfileViewMode) async throws -> ProfileMainScreenModel {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        switch mode {
        case .myProfile:
            return ProfileMainMocks.ownProfile
            
        case .otherUserProfile:
            return ProfileMainMocks.otherProfile
        }
    }
    
    func createDirectChat(with personID: String) async throws -> ChatSessionInput {
        let room = try await client.createDirectChat(participantID: personID)
        return ChatSessionInput(response: room)
    }
    
    func toggleFollow(for userID: Int, isFollowing: Bool) async throws {
        let personID = String(userID)
        
        if isFollowing {
            try await client.unfollowPerson(id: personID)
        } else {
            try await client.followPerson(id: personID)
        }
    }
}
