import Foundation
import SwiftUI
import GymbroTypes

enum SettingsSectionsBuilder {
    
    static func makeSections(state: ProfilePrivacySettingsState) -> [SettingsSection] {
        [
            SettingsSection(
                id: "account",
                title: String(localized: "settings.section.account", bundle: .module),
                items: [
                    .init(
                        id: "change_password",
                        title: String(localized: "settings.row.change_password", bundle: .module),
                        icon: "key.fill",
                        type: .navigation
                    ),
                    .init(
                        id: "devices",
                        title: String(localized: "settings.row.connected_devices", bundle: .module),
                        icon: "iphone.and.arrow.forward",
                        type: .navigation
                    ),
                    .init(
                        id: "language",
                        title: String(localized: "settings.row.language", bundle: .module),
                        icon: "globe",
                        type: .navigation
                    ),
                    .init(
                        id: "delete_account",
                        title: String(localized: "settings.row.delete_account", bundle: .module),
                        icon: "trash.fill",
                        type: .destructive
                    )
                ]
            ),
            
            SettingsSection(
                id: "notifications",
                title: String(localized: "settings.section.notifications", bundle: .module),
                items: [
                    .init(
                        id: "push",
                        title: String(localized: "settings.row.push", bundle: .module),
                        icon: "bell.fill",
                        type: .toggle(isOn: state.pushNotificationsEnabled)
                    ),
                    .init(
                        id: "workout_reminders",
                        title: String(localized: "settings.row.workout_reminders", bundle: .module),
                        icon: "figure.run",
                        type: .toggle(isOn: state.workoutRemindersEnabled)
                    )
                ]
            ),
            
            SettingsSection(
                id: "appearance",
                title: String(localized: "settings.section.appearance", bundle: .module),
                items: [
                    .init(
                        id: "dark_mode",
                        title: String(localized: "settings.row.dark_mode", bundle: .module),
                        icon: "moon.fill",
                        type: .toggle(isOn: true)
                    ),
                    .init(
                        id: "app_icon",
                        title: String(localized: "settings.row.app_icon", bundle: .module),
                        icon: "app.fill",
                        type: .navigation
                    )
                ]
            ),
            
            SettingsSection(
                id: "privacy",
                title: String(localized: "settings.section.privacy", bundle: .module),
                items: [
                    .init(
                        id: "private_account",
                        title: String(localized: "settings.row.private_account", bundle: .module),
                        icon: "lock.fill",
                        type: .toggle(isOn: state.privateAccountEnabled)
                    ),
                    .init(
                        id: "show_activity",
                        title: String(localized: "settings.row.show_activity", bundle: .module),
                        icon: "eye.fill",
                        type: .toggle(isOn: state.showActivityEnabled)
                    ),
                    .init(
                        id: "discover_visibility",
                        title: String(localized: "settings.row.discover", bundle: .module),
                        icon: "magnifyingglass",
                        type: .toggle(isOn: state.discoverVisibilityEnabled)
                    ),
                    .init(
                        id: "blocked_users",
                        title: String(localized: "settings.row.blocked_users", bundle: .module),
                        icon: "hand.raised.fill",
                        type: .navigation
                    )
                ]
            ),
            
            SettingsSection(
                id: "help_about",
                title: String(localized: "settings.section.help", bundle: .module),
                items: [
                    .init(
                        id: "help_center",
                        title: String(localized: "settings.row.help_center", bundle: .module),
                        icon: "questionmark.circle",
                        type: .navigation
                    ),
                    .init(
                        id: "support",
                        title: String(localized: "settings.row.contact_support", bundle: .module),
                        icon: "message.fill",
                        type: .navigation
                    ),
                    .init(
                        id: "terms",
                        title: String(localized: "settings.row.terms", bundle: .module),
                        icon: "doc.text.fill",
                        type: .navigation
                    ),
                    .init(
                        id: "privacy_policy",
                        title: String(localized: "settings.row.privacy_policy", bundle: .module),
                        icon: "shield.fill",
                        type: .navigation
                    ),
                    .init(
                        id: "app_version",
                        title: String(localized: "settings.row.app_version", bundle: .module),
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
                        title: String(localized: "settings.row.logout", bundle: .module),
                        icon: "rectangle.portrait.and.arrow.right",
                        type: .destructive
                    )
                ]
            )
        ]
    }
}
