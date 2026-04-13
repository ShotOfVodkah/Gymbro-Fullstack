import Foundation

public struct ChatRoomResponse: Decodable {
    let id: String
    public let kind: String
    let title: String?
    let description: String?
    let participants: [ChatParticipantResponse]
}

public struct ChatParticipantResponse: Decodable {
    let id: String
    let name: String
    let avatar_system_name: String
}

public struct ChatMessageResponse: Decodable {
    let id: String
    let sender_id: String
    let sender_name: String
    let sender_avatar_system_name: String
    let sent_at: Date
    let is_mine: Bool
    let kind: String
    let text: String?
    let workout: ChatWorkoutAttachmentResponse?
    let reactions: [ChatReactionResponse]
}

public struct ChatWorkoutAttachmentResponse: Decodable {
    let session_id: String?
    let title: String
    let subtitle: String
    let duration: String
    let category: String
}

public struct ChatReactionResponse: Decodable {
    let emoji: String
    let count: Int
    let is_selected_by_me: Bool
}
