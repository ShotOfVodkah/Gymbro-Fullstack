import Foundation

public struct ChatGroupInfo: Hashable {
    public var title: String
    public var description: String
    public var participants: [ChatParticipant]

    public init(
        title: String,
        description: String,
        participants: [ChatParticipant]
    ) {
        self.title = title
        self.description = description
        self.participants = participants
    }
}

extension ChatGroupInfo {
    public init(response: ChatRoomResponse) {
        self.init(
            title: response.title ?? "Group",
            description: response.description ?? "",
            participants: response.participants.map(ChatParticipant.init(response:))
        )
    }
}
