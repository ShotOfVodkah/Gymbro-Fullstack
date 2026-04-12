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
        if participants.count == 2, let person = participants.first {
            return .direct(person: person)
        } else {
            return .group(members: participants)
        }
    }
    
    public var isDirect: Bool {
        participants.count == 2
    }
    
    public var isGroup: Bool {
        participants.count > 2
    }
}

extension ChatSessionInput {
    public init(response: ChatRoomResponse) {
        self.init(
            chatID: response.id,
            title: response.title ?? defaultChatTitle(from: response),
            participants: response.participants.map(ChatParticipant.init(response:))
        )
    }
}

private func defaultChatTitle(from response: ChatRoomResponse) -> String {
    if response.kind == "direct" {
        return response.participants.first?.name ?? "Chat"
    } else {
        return response.title ?? "Group"
    }
}
