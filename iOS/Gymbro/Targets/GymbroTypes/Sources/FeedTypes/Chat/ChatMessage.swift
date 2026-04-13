import Foundation

public struct ChatMessage: Hashable, Identifiable {
    public let id: String
    public let senderID: String
    public let senderName: String
    public let senderAvatarSystemName: String
    public let sentAt: Date
    public let isMine: Bool
    public let kind: ChatMessageKind
    public var reactions: [ChatReaction]
    
    public init(
        id: String,
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

extension ChatMessage {
    public init(response: ChatMessageResponse) {
        let kind: ChatMessageKind
        
        switch response.kind {
        case "text":
            kind = .text(response.text ?? "")
            
        case "workout":
            let workout = response.workout
            kind = .workout(
                sessionID: workout?.session_id ?? "",
                title: workout?.title ?? "Workout",
                subtitle: workout?.subtitle ?? "",
                duration: workout?.duration ?? "",
                category: workout?.category ?? ""
            )
            
        default:
            kind = .text(response.text ?? "")
        }
        
        self.init(
            id: response.id,
            senderID: response.sender_id,
            senderName: response.sender_name,
            senderAvatarSystemName: response.sender_avatar_system_name,
            sentAt: response.sent_at,
            isMine: response.is_mine,
            kind: kind,
            reactions: response.reactions.map(ChatReaction.init(response:))
        )
    }
}
