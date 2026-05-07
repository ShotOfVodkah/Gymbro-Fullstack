import Foundation
import Combine
import GymbroNetwork

@MainActor
public final class SessionManager: ObservableObject {
    
    public static let shared = SessionManager()

    private static var authServiceOverride: (any AuthServiceProtocol)?

    public static func setAuthServiceOverride(_ auth: (any AuthServiceProtocol)?) {
        authServiceOverride = auth
    }
    
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
        let hasRefresh = (AppMicroservices.tokens.refreshToken?.isEmpty == false)
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
        
    #if DEBUG
    public static let uiTestingUserId = "1"

    public func setUITestingAuthenticatedSession() {
        AppMicroservices.tokens.accessToken = "ui-testing-access-token"
        AppMicroservices.tokens.refreshToken = "ui-testing-refresh-token"
        AppMicroservices.tokens.userId = Self.uiTestingUserId
        isAuthenticated = true
    }
    #endif
    
    public func logout() async {
        let auth: any AuthServiceProtocol = Self.authServiceOverride ?? AppMicroservices.auth
        do {
            try await auth.logout()
            print("Logout request success")
        } catch {
            print("Logout request failed: \(error.localizedDescription)")
        }
        
        AppMicroservices.tokens.clear()
        isAuthenticated = false
        AuthEvents.onSessionCleared?()
    }
    
    public func forceLogoutLocally() {
        AppMicroservices.tokens.clear()
        isAuthenticated = false
        AuthEvents.onSessionCleared?()
        print("Forced log out(((")
    }
}
