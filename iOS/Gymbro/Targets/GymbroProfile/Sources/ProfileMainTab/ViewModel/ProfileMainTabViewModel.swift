import Foundation
import GymbroAuth

@MainActor
final class ProfileMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var isLoggingOut: Bool = false
    
    public init() {
        screenState = .loaded
    }
    
    func logout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        
        Task {
            await SessionManager.shared.logout()
            isLoggingOut = false
        }
    }
}
