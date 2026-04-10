import Foundation

public struct ChatSessionInput: Hashable {
    public let chatID: String?
    public let title: String
    public let participants: [ChatParticipant]
    
    public init(
        chatID: String? = nil,
        title: String,
        participants: [ChatParticipant]
    ) {
        self.chatID = chatID
        self.title = title
        self.participants = participants
    }
    
    public var presentationStyle: ChatPresentationStyle {
        if participants.count == 1, let person = participants.first {
            return .direct(person: person)
        } else {
            return .group(members: participants)
        }
    }
    
    public var isDirect: Bool {
        participants.count == 1
    }
    
    public var isGroup: Bool {
        participants.count > 1
    }
}
