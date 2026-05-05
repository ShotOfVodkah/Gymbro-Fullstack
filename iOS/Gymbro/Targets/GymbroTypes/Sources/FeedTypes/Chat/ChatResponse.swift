import Foundation

public struct ChatRoomResponse: Decodable, Sendable {
    public let id: String
    public let kind: String
    let title: String?
    let description: String?
    public let participants: [ChatParticipantResponse]
}

public struct ChatParticipantResponse: Decodable, Sendable {
    public let id: String
    let name: String
    let avatar_system_name: String
}

public struct ChatMessageResponse: Decodable, Sendable {
    public let id: String
    public let sender_id: String
    public let sender_name: String
    public let sender_avatar_system_name: String
    public let sent_at: Date
    public let is_mine: Bool
    public let kind: String
    public let text: String?
    public let workout: ChatWorkoutAttachmentResponse?
    public let challenge_id: String?
    public let reactions: [ChatReactionResponse]
    
    public init(
        id: String,
        sender_id: String,
        sender_name: String,
        sender_avatar_system_name: String,
        sent_at: Date,
        is_mine: Bool,
        kind: String,
        text: String?,
        workout: ChatWorkoutAttachmentResponse?,
        challenge_id: String?,
        reactions: [ChatReactionResponse]
    ) {
        self.id = id
        self.sender_id = sender_id
        self.sender_name = sender_name
        self.sender_avatar_system_name = sender_avatar_system_name
        self.sent_at = sent_at
        self.is_mine = is_mine
        self.kind = kind
        self.text = text
        self.workout = workout
        self.challenge_id = challenge_id
        self.reactions = reactions
    }
}

public struct ChatWorkoutAttachmentResponse: Decodable, Sendable {
    let session_id: String?
    let title: String
    let subtitle: String
    let duration: String
    let category: String
}

public struct ChatReactionResponse: Decodable, Sendable {
    let emoji: String
    let count: Int
    let is_selected_by_me: Bool
}
