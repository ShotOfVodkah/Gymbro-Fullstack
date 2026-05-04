import Foundation

public struct FeedCommunity: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let displayTitle: String
    public let icon: String
    public let isSystemImage: Bool
    public let kind: FeedCommunityKind
    public let participants: [PersonItem]
    public let unreadCount: Int
    public let lastMessagePreview: String?
    public let lastMessageAt: Date?

    public init(
        id: String,
        title: String,
        displayTitle: String,
        icon: String,
        isSystemImage: Bool = false,
        kind: FeedCommunityKind,
        participants: [PersonItem] = [],
        unreadCount: Int = 0,
        lastMessagePreview: String? = nil,
        lastMessageAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.displayTitle = displayTitle
        self.icon = icon
        self.isSystemImage = isSystemImage
        self.kind = kind
        self.participants = participants
        self.unreadCount = unreadCount
        self.lastMessagePreview = lastMessagePreview
        self.lastMessageAt = lastMessageAt
    }
}

public enum FeedCommunityKind: Hashable {
    case directPerson
    case joinedGroup
}

extension FeedCommunity {
    public init(response: FeedCommunityItemResponse) {
        self.id = response.id
        self.title = response.title
        self.displayTitle = response.display_title
        self.icon = response.icon
        self.isSystemImage = response.is_system_image
        self.kind = response.kind == "direct" ? .directPerson : .joinedGroup
        self.participants = []
        self.unreadCount = response.unread_count
        self.lastMessagePreview = response.last_message_preview
        self.lastMessageAt = response.last_message_at
    }
}
