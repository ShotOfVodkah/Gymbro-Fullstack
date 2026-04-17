import Foundation
import GymbroAuth
import GymbroNavigation
import GymbroTypes

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var sections: [SettingsSection] = []
    
    @Published var legalSheetType: LegalDocType = .terms
    @Published var isLegalSheetPresented: Bool = false
    @Published var isShowingAppVersionAlert: Bool = false
    
    private let router: any Router
    private let service: any SettingsServiceProtocol
    private let analytics: any AnalyticsService
    
    init(
        router: any Router,
        service: any SettingsServiceProtocol,
        analytics: any AnalyticsService
    ) {
        self.router = router
        self.service = service
        self.analytics = analytics
        
        reload()
    }
    
    func reload() {
        Task {
            await load()
        }
    }
    
    private func load() async {
        screenState = .loading
        
        do {
            sections = try await service.fetchSettings()
            screenState = .loaded
        } catch {
            screenState = .error
        }
    }
    
    func openLegal(_ type: LegalDocType) {
        legalSheetType = type
        isLegalSheetPresented = true
    }

    func openAppVersionInfo() {
        isShowingAppVersionAlert = true
    }
    
    var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        
        return "GymBro\nVersion \(version)\nBuild \(build)"
    }
    
    func handleTap(_ item: SettingsItem) {
        switch item.id {
        case "change_password":
            print("Open change password")
            
        case "devices":
            print("Open connected devices")
            
        case "language":
            print("Open language settings")
            
        case "app_icon":
            print("Open app icon selection")
            
        case "blocked_users":
            print("Open blocked users")
            
        case "help_center":
            print("Open help center")
            
        case "support":
            print("Open contact support")
            
        case "terms":
            openLegal(.terms)
            
        case "privacy_policy":
            openLegal(.privacy)
            
        case "app_version":
            openAppVersionInfo()
            
        case "delete_account":
            print("Delete account tapped")
            
        case "logout":
            logout()
            
        default:
            break
        }
    }
    
    func toggle(_ item: SettingsItem) {
        guard case let .toggle(isOn) = item.type else { return }
        
        if let sectionIndex = sections.firstIndex(where: { $0.items.contains(item) }),
           let itemIndex = sections[sectionIndex].items.firstIndex(of: item) {
            
            sections[sectionIndex].items[itemIndex] = SettingsItem(
                id: item.id,
                title: item.title,
                icon: item.icon,
                type: .toggle(isOn: !isOn)
            )
        }
    }
    
    private func logout() {
        Task {
            await SessionManager.shared.logout()
            analytics.track(.userLoggedOut)
            router.popToRoot()
        }
    }
}
