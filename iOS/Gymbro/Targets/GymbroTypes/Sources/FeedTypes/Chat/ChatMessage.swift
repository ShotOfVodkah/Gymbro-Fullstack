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
                title: workout?.title ?? String(localized: "chat.fallback.workout", bundle: .module),
                subtitle: workout?.subtitle ?? "",
                duration: workout?.duration ?? "",
                category: workout?.category ?? ""
            )
            
        case "challenge_joined":
            kind = .challengeSystem(
                challengeID: response.challenge_id ?? "",
                title: "Challenge Joined",
                message: response.text ?? "",
                status: .inProgress
            )

        case "challenge_completed":
            kind = .challengeSystem(
                challengeID: response.challenge_id ?? "",
                title: "Challenge Completed",
                message: response.text ?? "",
                status: .completed
            )

        case "challenge_failed":
            kind = .challengeSystem(
                challengeID: response.challenge_id ?? "",
                title: "Challenge Failed",
                message: response.text ?? "",
                status: .failed
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
    
    public init(
        response: ChatMessageResponse,
        currentUserID: String
    ) {
        self.init(
            response: ChatMessageResponse(
                id: response.id,
                sender_id: response.sender_id,
                sender_name: response.sender_name,
                sender_avatar_system_name: response.sender_avatar_system_name,
                sent_at: response.sent_at,
                is_mine: response.sender_id == currentUserID,
                kind: response.kind,
                text: response.text,
                workout: response.workout,
                challenge_id: response.challenge_id,
                reactions: response.reactions
            )
        )
    }
}
