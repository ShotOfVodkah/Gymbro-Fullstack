import Foundation
import GymbroTypes

public final class ProfileClient {
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    private let client: NetworkClient
    
    public func fetchMyProfileForEdit() async throws -> EditProfileResponse {
        try await client.request(
            method: .GET,
            path: "profiles/me",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: EditProfileResponse.self
        )
    }
    
    public func updateMyProfile(_ request: UpdateProfileRequest) async throws -> EditProfileResponse {
        try await client.request(
            method: .PATCH,
            path: "profiles/me",
            body: request,
            requiresAuth: true,
            responseType: EditProfileResponse.self
        )
    }
    
    public func fetchMyStatistics() async throws -> ProfileStatisticsResponse {
        try await client.request(
            method: .GET,
            path: "profiles/me/statistics",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ProfileStatisticsResponse.self
        )
    }
    
    public func fetchStatistics(userID: Int) async throws -> ProfileStatisticsResponse {
        try await client.request(
            method: .GET,
            path: "profiles/\(userID)/statistics",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ProfileStatisticsResponse.self
        )
    }
    
    public func fetchMySettings() async throws -> ProfileSettingsResponse {
        try await client.request(
            method: .GET,
            path: "profiles/me/settings",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ProfileSettingsResponse.self
        )
    }
    
    public func updateMySettings(_ request: UpdateProfileSettingsRequest) async throws -> ProfileSettingsResponse {
        try await client.request(
            method: .PATCH,
            path: "profiles/me/settings",
            body: request,
            requiresAuth: true,
            responseType: ProfileSettingsResponse.self
        )
    }
    
    public func fetchMyMainProfile() async throws -> ProfileMainResponse {
        try await client.request(
            method: .GET,
            path: "profiles/me/main",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ProfileMainResponse.self
        )
    }
    
    public func fetchMainProfile(userID: Int) async throws -> ProfileMainResponse {
        try await client.request(
            method: .GET,
            path: "profiles/\(userID)/main",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ProfileMainResponse.self
        )
    }
}
