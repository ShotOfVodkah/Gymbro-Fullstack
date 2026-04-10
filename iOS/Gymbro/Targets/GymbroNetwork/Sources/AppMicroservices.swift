import Foundation

public final class AppMicroservices {
    public static let shared = AppMicroservices()
    
    public let tokenStorage: TokenStorage
    public let authService: AuthService
    public let workoutsClient: WorkoutsClient
    
    public let networkClient: NetworkClient
    
    private init() {
        let storage = KeychainTokenStorage()
        tokenStorage = storage
        
        let refreshClient = NetworkClient(baseURL: "http://localhost:8080")
        let refreshAuthService = AuthService(client: refreshClient)
        
        networkClient = NetworkClient(
            baseURL: "http://localhost:8080",
            tokenProvider: { storage.accessToken },
            refreshHandler: {
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
        )
        authService = AuthService(client: networkClient)
        workoutsClient = WorkoutsClient(client: networkClient)
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
}
