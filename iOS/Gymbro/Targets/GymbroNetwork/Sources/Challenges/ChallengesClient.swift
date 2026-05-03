import Foundation
import GymbroTypes

public protocol ChallengesClient {
    func fetchChallenges() async throws -> ChallengesListResponse
    func fetchChallengeDetails(id: String) async throws -> ChallengeDetailsResponse
    func fetchAvailableTeams(challengeID: String) async throws -> AvailableChallengeTeamsResponse
    func joinChallenge(challengeID: String, chatID: String) async throws -> JoinChallengeResponse
    func leaveChallenge(challengeID: String, teamID: String) async throws -> LeaveChallengeResponse
    func fetchLeaderboard(challengeID: String) async throws -> ChallengeLeaderboardResponse
    func fetchActivity(challengeID: String) async throws -> [ChallengeActivityResponse]
}

public final class ChallengesClientImpl: ChallengesClient {

    private let client: NetworkClient
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    public func fetchChallenges() async throws -> ChallengesListResponse {
        try await client.request(
            method: .GET,
            path: "/challenges",
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: ChallengesListResponse.self
        )
    }
    
    public func fetchChallengeDetails(id: String) async throws -> ChallengeDetailsResponse {
        try await client.request(
            method: .GET,
            path: "/challenges/\(id)",
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: ChallengeDetailsResponse.self
        )
    }
    
    public func fetchAvailableTeams(challengeID: String) async throws -> AvailableChallengeTeamsResponse {
        try await client.request(
            method: .GET,
            path: "/challenges/\(challengeID)/available-teams",
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: AvailableChallengeTeamsResponse.self
        )
    }
    
    public func joinChallenge(
        challengeID: String,
        chatID: String
    ) async throws -> JoinChallengeResponse {
        let request = JoinChallengeRequest(chatID: chatID)
        
        return try await client.request(
            method: .POST,
            path: "/challenges/\(challengeID)/join",
            body: request,
            requiresAuth: true,
            responseType: JoinChallengeResponse.self
        )
    }
    
    public func leaveChallenge(
        challengeID: String,
        teamID: String
    ) async throws -> LeaveChallengeResponse {
        let request = LeaveChallengeRequest(teamID: teamID)
        
        return try await client.request(
            method: .POST,
            path: "/challenges/\(challengeID)/leave",
            body: request,
            requiresAuth: true,
            responseType: LeaveChallengeResponse.self
        )
    }
    
    public func fetchLeaderboard(challengeID: String) async throws -> ChallengeLeaderboardResponse {
        try await client.request(
            method: .GET,
            path: "/challenges/\(challengeID)/leaderboard",
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: ChallengeLeaderboardResponse.self
        )
    }
    
    public func fetchActivity(challengeID: String) async throws -> [ChallengeActivityResponse] {
        try await client.request(
            method: .GET,
            path: "/challenges/\(challengeID)/activity",
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: [ChallengeActivityResponse].self
        )
    }
}
