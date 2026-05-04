import Foundation

public struct ChatRealtimeEventResponse: Decodable, Sendable {
    public let type: String
    public let chat_id: String
    public let actor_id: String?
    public let payload: ChatRealtimePayload?
    public let created_at: Date
}

public struct MarkChatReadRequest: Encodable, Sendable {
    public let last_read_message_id: String?
    
    public init(last_read_message_id: String?) {
        self.last_read_message_id = last_read_message_id
    }
}

public enum ChatRealtimePayload: Decodable, Sendable {
    case message(ChatMessageResponse)
    case reactionUpdated(ChatReactionUpdatedResponse)
    case room(ChatRoomResponse)
    case read(ChatReadResponse)
    case typing(ChatTypingResponse)
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let message = try? container.decode(ChatMessageResponse.self) {
            self = .message(message)
            return
        }

        if let reaction = try? container.decode(ChatReactionUpdatedResponse.self) {
            self = .reactionUpdated(reaction)
            return
        }

        if let room = try? container.decode(ChatRoomResponse.self) {
            self = .room(room)
            return
        }

        if let read = try? container.decode(ChatReadResponse.self) {
            self = .read(read)
            return
        }

        if let typing = try? container.decode(ChatTypingResponse.self) {
            self = .typing(typing)
            return
        }

        self = .unknown
    }
}

public struct ChatReactionUpdatedResponse: Decodable, Sendable {
    public let message_id: String
    public let reactions: [ChatReactionResponse]
}

public struct ChatReadResponse: Decodable, Sendable {
    public let community_id: String
    public let user_id: String
    public let last_read_message_id: String?
    public let last_read_at: Date
}

public struct ChatTypingResponse: Decodable, Sendable {
    public let user_id: String
    public let is_typing: Bool
}
