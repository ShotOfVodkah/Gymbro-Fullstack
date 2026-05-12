import Foundation
import UIKit

import GymbroAuth
import GymbroNavigation
import GymbroTypes

private enum SettingsExternalLink {
    /// Replace with your real help URL when the site is live.
    static let helpCenter = URL(string: "https://gymbro.app/help")!
    static let supportMail = URL(string: "mailto:support@gymbro.app?subject=GymBro%20Support")!
}

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
    @Published var activeInfo: SettingsInfoPresentation?

    private let router: any Router
    private let service: any SettingsServiceProtocol
    private let analytics: any AnalyticsService
    private let invalidationCenter: ProfileStateInvalidationCenter

    private var invalidationTask: Task<Void, Never>?
    private var didAttemptInitialLoad = false
    private var didTrackScreenOpen = false
    private var lastRefreshAt: Date?
    private var isRefreshing = false

    init(
        router: any Router,
        service: any SettingsServiceProtocol,
        analytics: any AnalyticsService,
        invalidationCenter: ProfileStateInvalidationCenter? = nil
    ) {
        self.router = router
        self.service = service
        self.analytics = analytics
        self.invalidationCenter = invalidationCenter ?? .shared

        bindInvalidationEvents()
    }

    deinit {
        invalidationTask?.cancel()
    }

    func loadIfNeeded() async {
        if !didTrackScreenOpen {
            didTrackScreenOpen = true
            analytics.track(.screenViewed(screen: .profileSettings))
        }

        guard !didAttemptInitialLoad else { return }
        didAttemptInitialLoad = true
        await load(showLoading: true)
    }

    func onAppear() {
        Task {
            await refreshIfStale()
        }
    }

    func refresh() async {
        await load(showLoading: false)
    }

    func reload() {
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.profileSettings.rawValue))
            await load(showLoading: true)
        }
    }

    private func refreshIfStale(maxAgeSeconds: TimeInterval = 15) async {
        let age = Date().timeIntervalSince(lastRefreshAt ?? .distantPast)
        guard age > maxAgeSeconds else { return }
        await refresh()
    }

    private func bindInvalidationEvents() {
        invalidationTask?.cancel()

        invalidationTask = Task { [weak self] in
            guard let self else { return }

            for await reason in invalidationCenter.events() {
                await self.handleInvalidation(reason)
            }
        }
    }

    private func handleInvalidation(_ reason: ProfileInvalidationReason) async {
        switch reason {
        case .accountChanged:
            await refresh()
        case .ownProfileDataChanged:
            break
        }
    }

    private func load(showLoading: Bool) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        if showLoading || screenState != .loaded {
            screenState = .loading
        }

        do {
            state = try await service.fetchState()
            sections = SettingsSectionsBuilder.makeSections(state: state)
            screenState = .loaded
            lastRefreshAt = Date()
        } catch {
            if screenState != .loaded || sections.isEmpty {
                screenState = .error
            }
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
            activeInfo = SettingsInfoPresentation(
                title: "Change Password",
                message: "Changing your password from this screen is not available yet. Sign out, then use “Forgot password” on the login screen, or contact support.",
                secondary: .openSupportMail
            )

        case "devices":
            isConnectedDevicesPresented = true

        case "language":
            activeInfo = SettingsInfoPresentation(
                title: "Language",
                message: "GymBro uses your device language. To change it, open iOS Settings → General → Language & Region (or open this app’s page in Settings below).",
                secondary: .openAppSettings
            )

        case "app_icon":
            activeInfo = SettingsInfoPresentation(
                title: "App Icon",
                message: "Alternate app icons are not available in this build yet.",
                secondary: nil
            )

        case "blocked_users":
            activeInfo = SettingsInfoPresentation(
                title: "Blocked Users",
                message: "Managing blocked users from the app is coming soon.",
                secondary: nil
            )

        case "help_center":
            openExternalURL(SettingsExternalLink.helpCenter)

        case "support":
            openExternalURL(SettingsExternalLink.supportMail)

        case "terms":
            openLegal(.terms)

        case "privacy_policy":
            openLegal(.privacy)

        case "app_version":
            openAppVersionInfo()

        case "delete_account":
            activeInfo = SettingsInfoPresentation(
                title: "Delete Account",
                message: "There is no in-app account deletion yet. To remove your account, contact support and we will process your request.",
                secondary: .openSupportMail
            )

        case "logout":
            logout()

        default:
            break
        }
    }

    func handleInfoSecondary(_ action: SettingsInfoPresentation.SecondaryAction) {
        switch action {
        case .openAppSettings:
            openAppSettingsURL()
        case .openSupportMail:
            openExternalURL(SettingsExternalLink.supportMail)
        }
    }

    private func openExternalURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func openAppSettingsURL() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openExternalURL(url)
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

struct SettingsInfoPresentation: Identifiable {
    enum SecondaryAction: Equatable {
        case openAppSettings
        case openSupportMail
    }

    let id = UUID()
    let title: String
    let message: String
    let secondary: SecondaryAction?
}
