import Foundation

public struct AvailableChallengeTeamModel: Identifiable, Hashable {
    public var id: String { chatID }
    
    public let chatID: String
    public let chatName: String
    public let avatarSystemName: String
    public let membersCount: Int
    public let canJoin: Bool
    public let reason: String?
    
    public init(
        chatID: String,
        chatName: String,
        avatarSystemName: String,
        membersCount: Int,
        canJoin: Bool,
        reason: String?
    ) {
        self.chatID = chatID
        self.chatName = chatName
        self.avatarSystemName = avatarSystemName
        self.membersCount = membersCount
        self.canJoin = canJoin
        self.reason = reason
    }
}

extension AvailableChallengeTeamModel {
    
    public init(response: AvailableChallengeTeamResponse) {
        self.init(
            chatID: response.chatID,
            chatName: response.chatName,
            avatarSystemName: response.avatarSystemName,
            membersCount: response.membersCount,
            canJoin: response.canJoin,
            reason: response.reason
        )
    }
}
