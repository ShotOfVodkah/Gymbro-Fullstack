import Foundation
import Combine
import GymbroNetwork

@MainActor
public final class SessionManager: ObservableObject {
    
    public static let shared = SessionManager()
    @Published public private(set) var isAuthenticated: Bool = false
    
    private init() {
        AuthEvents.onSessionExpired = { [weak self] in
            self?.forceLogoutLocally()
        }
        restoreSession()
    }
    
    private func restoreSession() {
//        let hasAccess = AppMicroservices.tokens.accessToken != nil
        let hasRefresh = AppMicroservices.tokens.refreshToken != nil
//        isAuthenticated = hasAccess || hasRefresh
        isAuthenticated = hasRefresh
    }
    
    func setSession(tokens: TokenResponse) {
        AppMicroservices.tokens.accessToken = tokens.access_token
        AppMicroservices.tokens.refreshToken = tokens.refresh_token
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
