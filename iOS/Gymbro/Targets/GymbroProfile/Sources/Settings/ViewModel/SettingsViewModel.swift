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
    @Published var state = ProfilePrivacySettingsState(
        pushNotificationsEnabled: true,
        workoutRemindersEnabled: true,
        privateAccountEnabled: false,
        showActivityEnabled: true,
        discoverVisibilityEnabled: true
    )
    
    @Published var legalSheetType: LegalDocType = .terms
    @Published var isLegalSheetPresented: Bool = false
    @Published var isShowingAppVersionAlert: Bool = false
    
    @Published var isConnectedDevicesPresented: Bool = false
    
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
        
        analytics.track(.screenViewed(screen: .profileSettings))
        Task { await load() }
    }
    
    func reload() {
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.profileSettings.rawValue))
            await load()
        }
    }
    
    private func load() async {
        screenState = .loading
        
        do {
            state = try await service.fetchState()
            sections = SettingsSectionsBuilder.makeSections(state: state)
            screenState = .loaded
        } catch {
            screenState = .error
            analytics.track(
                .errorOccurred(
                    screen: AnalyticsScreen.profileSettings.rawValue,
                    message: error.localizedDescription
                )
            )
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
        analytics.track(.settingsRowOpened(itemId: item.id))
        switch item.id {
        case "change_password":
            print("Open change password")
            
        case "devices":
            isConnectedDevicesPresented = true
            
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
        
        let oldState = state
        let newValue = !isOn
        
        switch item.id {
        case "push":
            state.pushNotificationsEnabled = newValue
        case "workout_reminders":
            state.workoutRemindersEnabled = newValue
        case "private_account":
            state.privateAccountEnabled = newValue
        case "show_activity":
            state.showActivityEnabled = newValue
        case "discover_visibility":
            state.discoverVisibilityEnabled = newValue
        case "dark_mode":
            sections = rebuildSectionsKeepingLocalDarkMode(itemID: item.id, value: newValue)
            return
        default:
            return
        }
        
        sections = SettingsSectionsBuilder.makeSections(state: state)
        
        Task {
            do {
                state = try await service.updateState(state)
                sections = SettingsSectionsBuilder.makeSections(state: state)
                analytics.track(.settingsToggleChanged(itemId: item.id, isOn: newValue))
            } catch {
                state = oldState
                sections = SettingsSectionsBuilder.makeSections(state: state)
                print("Failed to update settings:", error)
                analytics.track(
                    .errorOccurred(
                        screen: AnalyticsScreen.profileSettings.rawValue,
                        message: error.localizedDescription
                    )
                )
            }
        }
    }
    
    private func rebuildSectionsKeepingLocalDarkMode(itemID: String, value: Bool) -> [SettingsSection] {
        var updatedSections = sections
        
        if let sectionIndex = updatedSections.firstIndex(where: { $0.items.contains(where: { $0.id == itemID }) }),
           let itemIndex = updatedSections[sectionIndex].items.firstIndex(where: { $0.id == itemID }) {
            let item = updatedSections[sectionIndex].items[itemIndex]
            updatedSections[sectionIndex].items[itemIndex] = SettingsItem(
                id: item.id,
                title: item.title,
                icon: item.icon,
                type: .toggle(isOn: value)
            )
        }
        
        return updatedSections
    }
    
    private func logout() {
        isConnectedDevicesPresented = false
        Task {
            await SessionManager.shared.logout()
            analytics.track(.userLoggedOut)
            router.popToRoot()
        }
    }
}
