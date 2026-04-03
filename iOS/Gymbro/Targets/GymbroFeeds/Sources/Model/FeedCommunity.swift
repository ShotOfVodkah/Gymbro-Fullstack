import Foundation

struct FeedCommunity: Identifiable, Hashable {
    let id: UUID
    let title: String
    let icon: String
    let isSystemImage: Bool
    let isGroup: Bool

    init(
        id: UUID = UUID(),
        title: String,
        icon: String,
        isSystemImage: Bool = false,
        isGroup: Bool = false,
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isSystemImage = isSystemImage
        self.isGroup = isGroup
    }
}
