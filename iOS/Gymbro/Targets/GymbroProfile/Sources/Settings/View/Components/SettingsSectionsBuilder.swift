import Foundation
import GymbroTypes

enum SettingsSectionsBuilder {
    
    static func makeSections(state: ProfilePrivacySettingsState) -> [SettingsSection] {
        [
            SettingsSection(
                id: "account",
                title: "Account",
                items: [
                    .init(
                        id: "change_password",
                        title: "Change Password",
                        icon: "key.fill",
                        type: .navigation
                    ),
                    .init(
                        id: "devices",
                        title: "Connected Devices",
                        icon: "iphone.and.arrow.forward",
                        type: .navigation
                    ),
                    .init(
                        id: "language",
                        title: "Language",
                        icon: "globe",
                        type: .navigation
                    ),
                    .init(
                        id: "delete_account",
                        title: "Delete Account",
                        icon: "trash.fill",
                        type: .destructive
                    )
                ]
            ),
            
            SettingsSection(
                id: "notifications",
                title: "Notifications",
                items: [
                    .init(
                        id: "push",
                        title: "Push Notifications",
                        icon: "bell.fill",
                        type: .toggle(isOn: state.pushNotificationsEnabled)
                    ),
                    .init(
                        id: "workout_reminders",
                        title: "Workout Reminders",
                        icon: "figure.run",
                        type: .toggle(isOn: state.workoutRemindersEnabled)
                    )
                ]
            ),
            
            SettingsSection(
                id: "appearance",
                title: "Appearance",
                items: [
                    .init(
                        id: "dark_mode",
                        title: "Dark Mode",
                        icon: "moon.fill",
                        type: .toggle(isOn: true)
                    ),
                    .init(
                        id: "app_icon",
                        title: "App Icon",
                        icon: "app.fill",
                        type: .navigation
                    )
                ]
            ),
            
            SettingsSection(
                id: "privacy",
                title: "Privacy",
                items: [
                    .init(
                        id: "private_account",
                        title: "Private Account",
                        icon: "lock.fill",
                        type: .toggle(isOn: state.privateAccountEnabled)
                    ),
                    .init(
                        id: "show_activity",
                        title: "Show Activity to Friends",
                        icon: "eye.fill",
                        type: .toggle(isOn: state.showActivityEnabled)
                    ),
                    .init(
                        id: "discover_visibility",
                        title: "Show Profile in Discover",
                        icon: "magnifyingglass",
                        type: .toggle(isOn: state.discoverVisibilityEnabled)
                    ),
                    .init(
                        id: "blocked_users",
                        title: "Blocked Users",
                        icon: "hand.raised.fill",
                        type: .navigation
                    )
                ]
            ),
            
            SettingsSection(
                id: "help_about",
                title: "Help & About",
                items: [
                    .init(
                        id: "help_center",
                        title: "Help Center",
                        icon: "questionmark.circle",
                        type: .navigation
                    ),
                    .init(
                        id: "support",
                        title: "Contact Support",
                        icon: "message.fill",
                        type: .navigation
                    ),
                    .init(
                        id: "terms",
                        title: "Terms of Service",
                        icon: "doc.text.fill",
                        type: .navigation
                    ),
                    .init(
                        id: "privacy_policy",
                        title: "Privacy Policy",
                        icon: "shield.fill",
                        type: .navigation
                    ),
                    .init(
                        id: "app_version",
                        title: "App Version",
                        icon: "info.circle.fill",
                        type: .navigation
                    )
                ]
            ),
            
            SettingsSection(
                id: "logout",
                title: "",
                items: [
                    .init(
                        id: "logout",
                        title: "Log Out",
                        icon: "rectangle.portrait.and.arrow.right",
                        type: .destructive
                    )
                ]
            )
        ]
    }
}
