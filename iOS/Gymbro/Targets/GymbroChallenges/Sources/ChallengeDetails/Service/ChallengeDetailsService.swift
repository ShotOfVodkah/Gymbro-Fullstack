import Foundation
import GymbroNetwork
import GymbroTypes

protocol ChallengeDetailsService {
    func fetchDetails(id: String) async throws -> ChallengeDetailsModel
    func fetchActivity(challengeID: String) async throws -> [ChallengeActivityModel]
    func fetchLeaderboard(challengeID: String) async throws -> [ChallengeLeaderboardTeamModel]
}

final class ChallengeDetailsServiceImpl: ChallengeDetailsService {
    
    init(client: any ChallengesClient) {
        self.client = client
    }
    
    func fetchDetails(id: String) async throws -> ChallengeDetailsModel {
        let response = try await client.fetchChallengeDetails(id: id)
        return ChallengeDetailsModel(response: response)
    }
    
    func fetchActivity(challengeID: String) async throws -> [ChallengeActivityModel] {
        let response = try await client.fetchActivity(challengeID: challengeID)
        return response.map { ChallengeActivityModel(response: $0) }
    }
    
    func fetchLeaderboard(challengeID: String) async throws -> [ChallengeLeaderboardTeamModel] {
        let response = try await client.fetchLeaderboard(challengeID: challengeID)
        return response.leaderboard.map { ChallengeLeaderboardTeamModel(response: $0) }
    }
    
    private let client: any ChallengesClient
}
