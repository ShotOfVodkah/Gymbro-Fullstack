import Foundation

struct FeedCommunity: Identifiable, Hashable {
    let id: UUID
    let title: String
    let icon: String
    let isSystemImage: Bool
    let kind: FeedCommunityKind
    let participants: [PersonItem]

    init(
        id: UUID = UUID(),
        title: String,
        icon: String,
        isSystemImage: Bool = false,
        kind: FeedCommunityKind,
        participants: [PersonItem] = []
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isSystemImage = isSystemImage
        self.kind = kind
        self.participants = participants
    }
}

enum FeedCommunityKind: Hashable {
    case directPerson
    case joinedGroup
}
