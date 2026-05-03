import Foundation

public struct JoinChallengeRequest: Encodable {
    public let chatID: String
    
    public init(chatID: String) {
        self.chatID = chatID
    }
    
    private enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
    }
}

public struct LeaveChallengeRequest: Encodable {
    public let teamID: String
    
    public init(teamID: String) {
        self.teamID = teamID
    }
    
    private enum CodingKeys: String, CodingKey {
        case teamID = "team_id"
    }
}
