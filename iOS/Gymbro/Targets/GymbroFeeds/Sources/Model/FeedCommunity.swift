import Foundation

struct FeedCommunity: Identifiable, Hashable {
    let id: UUID
    let title: String
    let icon: String
    let isSystemImage: Bool
    let kind: FeedCommunityKind

    init(
        id: UUID = UUID(),
        title: String,
        icon: String,
        isSystemImage: Bool = false,
        kind: FeedCommunityKind,
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isSystemImage = isSystemImage
        self.kind = kind
    }
}

enum FeedCommunityKind: Hashable {
    case directPerson
    case joinedGroup
}
