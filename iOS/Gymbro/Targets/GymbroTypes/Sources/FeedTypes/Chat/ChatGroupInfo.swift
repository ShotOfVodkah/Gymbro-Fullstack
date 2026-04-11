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
