import Foundation
import GymbroTypes

public extension FeedsClient {
    
    func fetchFriends() async throws -> [PersonItemResponse] {
        try await client.request(
            method: .GET,
            path: "people/friends",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [PersonItemResponse].self
        )
    }

    func fetchFollowing() async throws -> [PersonItemResponse] {
        try await client.request(
            method: .GET,
            path: "people/following",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [PersonItemResponse].self
        )
    }

    func fetchDiscoverPeople(query: String? = nil) async throws -> [PersonItemResponse] {
        let queryItems: [URLQueryItem]? = {
            guard let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return nil
            }
            return [URLQueryItem(name: "q", value: query)]
        }()

        return try await client.request(
            method: .GET,
            path: "people/discover",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [PersonItemResponse].self
        )
    }

    func fetchPerson(id: String) async throws -> PersonItemResponse {
        try await client.request(
            method: .GET,
            path: "people/\(id)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: PersonItemResponse.self
        )
    }

    func followPerson(id: String) async throws {
        try await client.requestVoid(
            method: .POST,
            path: "people/\(id)/follow",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }

    func unfollowPerson(id: String) async throws {
        try await client.requestVoid(
            method: .DELETE,
            path: "people/\(id)/follow",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }
    
    func fetchFriendsByUser(userID: String) async throws -> [PersonItemResponse] {
        try await client.request(
            method: .GET,
            path: "people/\(userID)/friends",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [PersonItemResponse].self
        )
    }

    func fetchFollowingByUser(userID: String) async throws -> [PersonItemResponse] {
        try await client.request(
            method: .GET,
            path: "people/\(userID)/following",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [PersonItemResponse].self
        )
    }
}
