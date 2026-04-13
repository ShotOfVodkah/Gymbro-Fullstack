import Foundation

public struct ChatParticipant: Hashable, Identifiable {
    public let id: String
    public let name: String
    public let avatarSystemName: String
    
    public init(id: String, name: String, avatarSystemName: String) {
        self.id = id
        self.name = name
        self.avatarSystemName = avatarSystemName
    }
}

extension ChatParticipant {
    public init(response: ChatParticipantResponse) {
        self.init(
            id: response.id,
            name: response.name,
            avatarSystemName: response.avatar_system_name
        )
    }
}
