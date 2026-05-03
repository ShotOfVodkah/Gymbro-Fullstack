import Foundation
import GymbroNetwork
import GymbroTypes

protocol ChallengeLeaderboardService {
    func fetchLeaderboard(challengeID: String) async throws -> [ChallengeLeaderboardTeamModel]
}

final class ChallengeLeaderboardServiceImpl: ChallengeLeaderboardService {
    
    init(client: any ChallengesClient) {
        self.client = client
    }
    
    func fetchLeaderboard(challengeID: String) async throws -> [ChallengeLeaderboardTeamModel] {
        let response = try await client.fetchLeaderboard(challengeID: challengeID)
        return response.leaderboard.map { ChallengeLeaderboardTeamModel(response: $0) }
    }
    
    private let client: any ChallengesClient
}
