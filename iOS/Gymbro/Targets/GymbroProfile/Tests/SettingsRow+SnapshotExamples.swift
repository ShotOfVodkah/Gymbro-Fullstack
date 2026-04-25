import GymbroTypes
import SwiftUI

@testable import GymbroProfile

enum SettingsRowSnapshotExamples {
    static let snapshotSize = CGSize(width: 360, height: 64)

    static let snapshotExamples: [SettingsRowSnapshotCase] = [
        SettingsRowSnapshotCase(
            name: "navigation",
            makeView: {
                SettingsRow(
                    item: SettingsItem(
                        id: "1",
                        title: "Account settings",
                        icon: "person.crop.circle",
                        type: .navigation
                    ),
                    onTap: {},
                    onToggle: { _ in }
                )
            }
        ),
        SettingsRowSnapshotCase(
            name: "toggle_on",
            makeView: {
                SettingsRow(
                    item: SettingsItem(
                        id: "2",
                        title: "Notifications",
                        icon: "bell.badge.fill",
                        type: .toggle(isOn: true)
                    ),
                    onTap: {},
                    onToggle: { _ in }
                )
            }
        ),
        SettingsRowSnapshotCase(
            name: "destructive",
            makeView: {
                SettingsRow(
                    item: SettingsItem(
                        id: "3",
                        title: "Delete account",
                        icon: "trash.fill",
                        type: .destructive
                    ),
                    onTap: {},
                    onToggle: { _ in }
                )
            }
        )
    ]
}

struct SettingsRowSnapshotCase {
    let name: String
    let makeView: () -> SettingsRow
}
