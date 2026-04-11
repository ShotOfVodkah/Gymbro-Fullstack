import Foundation
import GymbroAuth
import GymbroTypes

@MainActor
final class ProfileMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var isLoggingOut: Bool = false

    private let analytics: any AnalyticsService

    public init(analytics: any AnalyticsService) {
        self.analytics = analytics
        screenState = .loaded
        analytics.track(.screenViewed(screen: .profile))
    }
    
    func logout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        
        Task {
            await SessionManager.shared.logout()
            analytics.track(.userLoggedOut)
            isLoggingOut = false
        }
    }
}
