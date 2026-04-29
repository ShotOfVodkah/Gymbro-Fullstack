import Foundation
import GymbroNetwork
import GymbroTypes

protocol JoinChallengeService {
    func fetchAvailableTeams(challengeID: String) async throws -> [AvailableChallengeTeamModel]
    func joinChallenge(challengeID: String, chatID: String) async throws
}

final class JoinChallengeServiceImpl: JoinChallengeService {
    
    init(client: any ChallengesClient) {
        self.client = client
    }
    
    func fetchAvailableTeams(challengeID: String) async throws -> [AvailableChallengeTeamModel] {
        let response = try await client.fetchAvailableTeams(challengeID: challengeID)
        return response.teams.map { AvailableChallengeTeamModel(response: $0) }
    }
    
    func joinChallenge(challengeID: String, chatID: String) async throws {
        _ = try await client.joinChallenge(challengeID: challengeID, chatID: chatID)
    }
    
    private let client: any ChallengesClient
}
