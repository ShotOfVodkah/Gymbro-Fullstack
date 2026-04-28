import Foundation
import GymbroTypes

public protocol PerksClient {
    func fetchDashboard() async throws -> PerksDashboardResponse
    func fetchStreak() async throws -> StreakResponse
    func updateWeeklyGoal(_ request: UpdateWeeklyGoalRequest) async throws -> PerksDashboardResponse
    func useStreakFreeze(_ request: UseStreakFreezeRequest) async throws -> PerksDashboardResponse
    func fetchAchievements() async throws -> [AchievementResponse]
    func fetchLeaderboard(filter: LeaderboardFilter, sort: LeaderboardSort) async throws -> [LeaderboardResponse]
    func sendPerksEvent(_ request: PerksEventRequest) async throws
}

public final class PerksClientImpl: PerksClient {
    
    private let client: NetworkClient
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    public func fetchDashboard() async throws -> PerksDashboardResponse {
        try await client.request(
            method: .GET,
            path: "/perks/me",
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: PerksDashboardResponse.self
        )
    }

    public func fetchStreak() async throws -> StreakResponse {
        try await client.request(
            method: .GET,
            path: "/perks/streak",
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: StreakResponse.self
        )
    }

    public func updateWeeklyGoal(_ request: UpdateWeeklyGoalRequest) async throws -> PerksDashboardResponse {
        try await client.request(
            method: .PATCH,
            path: "/perks/streak/goal",
            body: request,
            requiresAuth: true,
            responseType: PerksDashboardResponse.self
        )
    }

    public func useStreakFreeze(_ request: UseStreakFreezeRequest) async throws -> PerksDashboardResponse {
        try await client.request(
            method: .POST,
            path: "/perks/streak/freeze/use",
            body: request,
            requiresAuth: true,
            responseType: PerksDashboardResponse.self
        )
    }

    public func fetchAchievements() async throws -> [AchievementResponse] {
        try await client.request(
            method: .GET,
            path: "/perks/achievements",
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: [AchievementResponse].self
        )
    }

    public func fetchLeaderboard(
        filter: LeaderboardFilter,
        sort: LeaderboardSort
    ) async throws -> [LeaderboardResponse] {
        try await client.request(
            method: .GET,
            path: "/perks/leaderboard",
            queryItems: [
                URLQueryItem(name: "filter", value: filter.rawValue),
                URLQueryItem(name: "sort", value: sort.rawValue)
            ],
            body: EmptyBody?.none,
            requiresAuth: true,
            responseType: [LeaderboardResponse].self
        )
    }

    public func sendPerksEvent(_ request: PerksEventRequest) async throws {
        try await client.requestVoid(
            method: .POST,
            path: "/perks/events",
            body: request,
            requiresAuth: true
        )
    }
}
