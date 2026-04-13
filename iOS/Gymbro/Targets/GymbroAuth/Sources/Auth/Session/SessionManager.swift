import Foundation
import Combine
import GymbroNetwork

@MainActor
public final class SessionManager: ObservableObject {
    
    public static let shared = SessionManager()
    
    @Published public private(set) var isAuthenticated: Bool = false
    
    public var currentUserId: String? {
        AppMicroservices.tokens.userId
    }
    
    private init() {
        AuthEvents.onSessionExpired = { [weak self] in
            self?.forceLogoutLocally()
        }
        restoreSession()
    }
    
    private func restoreSession() {
        let hasRefresh = AppMicroservices.tokens.refreshToken != nil
        isAuthenticated = hasRefresh
        
        if AppMicroservices.tokens.userId == nil,
           let accessToken = AppMicroservices.tokens.accessToken {
            AppMicroservices.tokens.userId = JWTClaimsParser.userId(fromAccessToken: accessToken)
        }
    }
    
    func setSession(tokens: TokenResponse) {
        AppMicroservices.tokens.accessToken = tokens.access_token
        AppMicroservices.tokens.refreshToken = tokens.refresh_token
        AppMicroservices.tokens.userId = JWTClaimsParser.userId(fromAccessToken: tokens.access_token)
        isAuthenticated = true
    }
    
    public func logout() async {
        do {
            try await AppMicroservices.auth.logout()
            print("Logout request success")
        } catch {
            print("Logout request failed: \(error.localizedDescription)")
        }
        
        AppMicroservices.tokens.clear()
        isAuthenticated = false
    }
    
    public func forceLogoutLocally() {
        AppMicroservices.tokens.clear()
        isAuthenticated = false
        print("Forced log out(((")
    }
}
