import Foundation

public enum WorkoutShareRecipientSection: String, CaseIterable, Identifiable {
    case feed
    case chats
    case friends

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .feed:
            return "Post to Feed"
        case .chats:
            return "Existing Chats"
        case .friends:
            return "Friends"
        }
    }
}

public struct ResolvedShareTargets {
    public let publishToFeed: Bool
    public let existingChatIDs: [String]
    public let directUserIDs: [String]

    public init(
        publishToFeed: Bool,
        existingChatIDs: [String],
        directUserIDs: [String]
    ) {
        self.publishToFeed = publishToFeed
        self.existingChatIDs = existingChatIDs
        self.directUserIDs = directUserIDs
    }
}
