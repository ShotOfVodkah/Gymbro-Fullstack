import Foundation
import GymbroNetwork
import GymbroTypes

protocol ChallengesMainTabService {
    func fetchChallenges() async throws -> [ChallengeCardModel]
}

final class ChallengesMainTabServiceImpl: ChallengesMainTabService {
    
    init(client: any ChallengesClient) {
        self.client = client
    }
    
    func fetchChallenges() async throws -> [ChallengeCardModel] {
        let response = try await client.fetchChallenges()
        return response.challenges.map { ChallengeCardModel(response: $0) }
    }
    
    private let client: any ChallengesClient
}
