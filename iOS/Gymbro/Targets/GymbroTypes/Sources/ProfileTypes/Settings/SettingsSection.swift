import Foundation

public struct SettingsSection: Identifiable, Hashable {
    public let id: String
    public let title: String
    public var items: [SettingsItem]
    
    public init(
        id: String,
        title: String,
        items: [SettingsItem]
    ) {
        self.id = id
        self.title = title
        self.items = items
    }
}
