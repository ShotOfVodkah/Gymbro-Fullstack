import Foundation

public enum ChatKind: String, Hashable {
    case direct
    case joinedGroup = "joined_group"
}

public struct ChatSessionInput: Hashable {
    public let chatID: String?
    public let title: String
    public let participants: [ChatParticipant]
    public let kind: ChatKind
    
    public init(
        chatID: String? = nil,
        title: String,
        participants: [ChatParticipant],
        kind: ChatKind
    ) {
        self.chatID = chatID
        self.title = title
        self.participants = participants
        self.kind = kind
    }
    
    public var presentationStyle: ChatPresentationStyle {
        switch kind {
        case .direct:
            let otherParticipant = participants.first
                ?? ChatParticipant(id: "", name: title, avatarSystemName: "person.circle.fill")
            return .direct(person: otherParticipant)
            
        case .joinedGroup:
            return .group(members: participants)
        }
    }
    
    public var isDirect: Bool {
        kind == .direct
    }
    
    public var isGroup: Bool {
        kind == .joinedGroup
    }
}

extension ChatSessionInput {
    public init(response: ChatRoomResponse) {
        let participants = response.participants.map(ChatParticipant.init(response:))
        let kind: ChatKind = response.kind == "direct" ? .direct : .joinedGroup
        
        let resolvedTitle: String = {
            if let title = response.title, !title.isEmpty {
                return title
            }
            return kind == .direct ? "Direct chat" : "Group chat"
        }()
        
        self.init(
            chatID: response.id,
            title: resolvedTitle,
            participants: participants,
            kind: kind
        )
    }
}
