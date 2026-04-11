import Foundation

public struct ChatMessage: Hashable, Identifiable {
    public let id: UUID
    public let senderID: String
    public let senderName: String
    public let senderAvatarSystemName: String
    public let sentAt: Date
    public let isMine: Bool
    public let kind: ChatMessageKind
    public var reactions: [ChatReaction]
    
    public init(
        id: UUID = UUID(),
        senderID: String,
        senderName: String,
        senderAvatarSystemName: String,
        sentAt: Date,
        isMine: Bool,
        kind: ChatMessageKind,
        reactions: [ChatReaction] = []
    ) {
        self.id = id
        self.senderID = senderID
        self.senderName = senderName
        self.senderAvatarSystemName = senderAvatarSystemName
        self.sentAt = sentAt
        self.isMine = isMine
        self.kind = kind
        self.reactions = reactions
    }
}

public struct ChatMessageDateSection: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let messages: [ChatMessage]

    public init(
        id: UUID = UUID(),
        title: String,
        messages: [ChatMessage]
    ) {
        self.id = id
        self.title = title
        self.messages = messages
    }
}
