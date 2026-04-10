import Foundation

struct ChatMessage: Hashable, Identifiable {
    let id: UUID
    let senderID: String
    let senderName: String
    let senderAvatarSystemName: String
    let sentAt: Date
    let isMine: Bool
    let kind: ChatMessageKind
    var reactions: [ChatReaction]
    
    init(
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

struct ChatMessageDateSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let messages: [ChatMessage]
}
