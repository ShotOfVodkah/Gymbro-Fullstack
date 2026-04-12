import Foundation

public struct CreateDirectChatRequest: Encodable {
    public let participant_id: String
    
    public init(participant_id: String) {
        self.participant_id = participant_id
    }
}

public struct CreateGroupChatRequest: Encodable {
    public let title: String
    public let description: String
    public let participant_ids: [String]
    
    public init(
        title: String,
        description: String,
        participant_ids: [String]
    ) {
        self.title = title
        self.description = description
        self.participant_ids = participant_ids
    }
}

public struct SendChatMessageRequest: Encodable {
    public let kind: String
    public let text: String?
    public let session_id: String?
    
    public init(
        kind: String,
        text: String?,
        session_id: String?
    ) {
        self.kind = kind
        self.text = text
        self.session_id = session_id
    }
}

public struct ToggleReactionRequest: Encodable {
    public let emoji: String
    
    public init(emoji: String) {
        self.emoji = emoji
    }
}

public struct UpdateGroupChatRequest: Encodable {
    public let title: String
    public let description: String
    
    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

public struct AddChatMembersRequest: Encodable {
    public let user_ids: [String]
    
    public init(user_ids: [String]) {
        self.user_ids = user_ids
    }
}
