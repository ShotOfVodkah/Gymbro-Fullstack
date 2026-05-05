import Foundation
import GymbroNetwork
import GymbroTypes

protocol FeedsPeopleService {
    func fetchScreen(input: PeopleScreenInput) async throws -> FeedsPeopleScreenData
    func fetchPerson(id: String) async throws -> PersonItem
    func toggleFollow(for person: PersonItem) async throws
    func createDirectChat(with personID: String) async throws -> ChatSessionInput
}

struct FeedsPeopleScreenData {
    let friends: [PersonItem]
    let following: [PersonItem]
    let discover: [PersonItem]
    let shouldShowDiscover: Bool
}

final class FeedsPeopleServiceImpl: FeedsPeopleService {
    
    init(client: any FeedsClientProtocol) {
        self.client = client
    }
    
    func fetchScreen(input: PeopleScreenInput) async throws -> FeedsPeopleScreenData {
        switch input {
        case .mine:
            async let friendsResponse = client.fetchFriends()
            async let followingResponse = client.fetchFollowing()
            async let discoverResponse = client.fetchDiscoverPeople(query: nil)
            
            let friends = try await friendsResponse.map(PersonItem.init(response:))
            let following = try await followingResponse.map(PersonItem.init(response:))
            let discover = try await discoverResponse.map(PersonItem.init(response:))
            
            let friendIDs = Set(friends.map(\.id))
            let followingIDs = Set(following.map(\.id))
            
            return FeedsPeopleScreenData(
                friends: friends,
                following: following.filter { !friendIDs.contains($0.id) },
                discover: discover.filter {
                    !friendIDs.contains($0.id) && !followingIDs.contains($0.id)
                },
                shouldShowDiscover: true
            )
            
        case .user(let userID, _):
            async let friendsResponse = client.fetchFriendsByUser(userID: String(userID))
            async let followingResponse = client.fetchFollowingByUser(userID: String(userID))
            
            let friends = try await friendsResponse.map(PersonItem.init(response:))
            let following = try await followingResponse.map(PersonItem.init(response:))
            
            let friendIDs = Set(friends.map(\.id))
            
            return FeedsPeopleScreenData(
                friends: friends,
                following: following.filter { !friendIDs.contains($0.id) },
                discover: [],
                shouldShowDiscover: false
            )
        }
    }
    
    func fetchPerson(id: String) async throws -> PersonItem {
        let response = try await client.fetchPerson(id: id)
        return PersonItem(response: response)
    }
    
    func toggleFollow(for person: PersonItem) async throws {
        if person.isFollowing {
            try await client.unfollowPerson(id: person.id)
        } else {
            try await client.followPerson(id: person.id)
        }
    }
    
    func createDirectChat(with personID: String) async throws -> ChatSessionInput {
        let room = try await client.createDirectChat(participantID: personID)
        return ChatSessionInput(response: room)
    }
    
    private let client: any FeedsClientProtocol
}
