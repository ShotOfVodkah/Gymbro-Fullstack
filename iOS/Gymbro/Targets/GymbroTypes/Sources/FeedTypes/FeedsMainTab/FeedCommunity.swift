import Foundation

public struct FeedCommunity: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let icon: String
    public let isSystemImage: Bool
    public let kind: FeedCommunityKind
    public let participants: [PersonItem]

    public init(
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

public enum FeedCommunityKind: Hashable {
    case directPerson
    case joinedGroup
}

extension FeedCommunity {
    public init(response: FeedCommunityItemResponse) {
        self.id = UUID(uuidString: response.id) ?? UUID()
        self.title = response.title
        self.icon = response.icon
        self.isSystemImage = response.is_system_image
        self.kind = Self.mapKind(response.kind)
        self.participants = []
    }

    private static func mapKind(_ rawValue: String) -> FeedCommunityKind {
        switch rawValue {
        case "direct":
            return .directPerson
        default:
            return .joinedGroup
        }
    }
}
