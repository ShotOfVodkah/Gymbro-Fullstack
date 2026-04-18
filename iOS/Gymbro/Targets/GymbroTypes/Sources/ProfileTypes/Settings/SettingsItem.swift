import Foundation

public struct SettingsItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let icon: String
    public let type: SettingsItemType
    
    public init(
        id: String,
        title: String,
        icon: String,
        type: SettingsItemType
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.type = type
    }
}
