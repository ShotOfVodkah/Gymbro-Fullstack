import Foundation

public enum SettingsItemType: Hashable {
    case navigation
    case toggle(isOn: Bool)
    case destructive
}
