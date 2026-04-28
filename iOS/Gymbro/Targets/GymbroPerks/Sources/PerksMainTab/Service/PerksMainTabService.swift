import Foundation
import GymbroNetwork
import GymbroTypes

protocol PerksMainTabService {
    func fetchDashboard() async throws -> PerksDashboard
    func updateWeeklyGoal(_ goal: Int) async throws -> PerksDashboard
    func useStreakFreeze() async throws -> PerksDashboard
    func sendPerksEvent(_ event: PerksEvent) async throws
    func fetchLeaderboard(filter: LeaderboardFilter, sort: LeaderboardSort) async throws -> [LeaderboardEntry]
}

final class PerksMainTabServiceImpl: PerksMainTabService {
    
    private let client: any PerksClient
    
    init(client: any PerksClient) {
        self.client = client
    }
    
    func fetchDashboard() async throws -> PerksDashboard {
        try await client.fetchDashboard().toModel()
    }
    
    func updateWeeklyGoal(_ goal: Int) async throws -> PerksDashboard {
        let request = UpdateWeeklyGoalRequest(weeklyGoal: goal)
        return try await client.updateWeeklyGoal(request).toModel()
    }
    
    func useStreakFreeze() async throws -> PerksDashboard {
        let request = UseStreakFreezeRequest()
        return try await client.useStreakFreeze(request).toModel()
    }
    
    func sendPerksEvent(_ event: PerksEvent) async throws {
        let request = PerksEventRequest(
            type: event.type.rawValue,
            metadata: event.metadata,
            createdAt: event.createdAt
        )
        
        try await client.sendPerksEvent(request)
    }
    
    func fetchLeaderboard(filter: LeaderboardFilter, sort: LeaderboardSort) async throws -> [LeaderboardEntry] {
        let response = try await client.fetchLeaderboard(filter: filter, sort: sort)
        return response.map { $0.toModel() }
    }
}
