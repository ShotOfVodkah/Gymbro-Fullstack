import Foundation

public final class AppMicroservices {
    public static let shared = AppMicroservices()
    
    public let tokenStorage: TokenStorage
    public let authService: AuthService
    public let workoutsClient: WorkoutsClient
    public let feedsClient: FeedsClient
    public let profileClient: ProfileClient
    public let perksClient: PerksClient
    public let perksEvents: PerksEventTrackingService
    public let challengesClient: ChallengesClient
    
    public let networkClient: NetworkClient
    
    private let refreshCoordinator = TokenRefreshCoordinator()
    
    private init() {
        let storage = KeychainTokenStorage()
        tokenStorage = storage
        
        let refreshClient = NetworkClient(baseURL: "http://localhost:8080")
        let refreshAuthService = AuthService(client: refreshClient)
        
        networkClient = NetworkClient(
            baseURL: "http://localhost:8080",
            tokenProvider: { storage.accessToken },
            refreshHandler: { [refreshCoordinator] in
                try await refreshCoordinator.refreshIfNeeded {
                    guard let refreshToken = storage.refreshToken, !refreshToken.isEmpty else {
                        print("No refresh token available")
                        await AppMicroservices.shared.handleSessionExpired()
                        return false
                    }
                    
                    print("Attempting token refresh...")
                    
                    do {
                        let tokens = try await refreshAuthService.refresh(refreshToken: refreshToken)
                        storage.accessToken = tokens.access_token
                        storage.refreshToken = tokens.refresh_token
                        storage.userId = JWTClaimsParser.userId(fromAccessToken: tokens.access_token)
                        
                        print("Token refresh successful")
                        return true
                    } catch {
                        print("Token refresh failed:", error)
                        await AppMicroservices.shared.handleSessionExpired()
                        return false
                    }
                }
            }
        )
        authService = AuthService(client: networkClient)
        workoutsClient = WorkoutsClient(client: networkClient)
        feedsClient = FeedsClient(client: networkClient)
        profileClient = ProfileClient(client: networkClient)
        perksClient = PerksClientImpl(client: networkClient)
        perksEvents = PerksEventTrackingServiceImpl(client: perksClient)
        challengesClient = ChallengesClientImpl(client: networkClient)
    }
    
    @MainActor
    private func handleSessionExpired() {
        tokenStorage.clear()
        AuthEvents.onSessionExpired?()
    }
}

extension AppMicroservices {
    public static var auth: AuthService { shared.authService }
    public static var tokens: TokenStorage { shared.tokenStorage }
    public static var workouts: WorkoutsClient { shared.workoutsClient }
    public static var feeds: FeedsClient { shared.feedsClient }
    public static var profile: ProfileClient { shared.profileClient }
    public static var perks: PerksClient { shared.perksClient }
    public static var perksEvents: PerksEventTrackingService { shared.perksEvents }
    public static var challenges: ChallengesClient { shared.challengesClient }
}
