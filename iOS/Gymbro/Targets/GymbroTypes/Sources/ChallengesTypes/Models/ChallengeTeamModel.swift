import Foundation

public struct ChallengeTeamModel: Identifiable, Hashable {
    public let id: String
    public let challengeID: String
    public let chatID: String
    public let teamName: String
    public let teamAvatar: String
    public let membersCount: Int
    public let currentValue: Int
    public let targetValue: Int
    public let progressPercent: Double
    public let status: ChallengeParticipationStatus
    public let joinedAt: Date?
    
    public init(
        id: String,
        challengeID: String,
        chatID: String,
        teamName: String,
        teamAvatar: String,
        membersCount: Int,
        currentValue: Int,
        targetValue: Int,
        progressPercent: Double,
        status: ChallengeParticipationStatus,
        joinedAt: Date?
    ) {
        self.id = id
        self.challengeID = challengeID
        self.chatID = chatID
        self.teamName = teamName
        self.teamAvatar = teamAvatar
        self.membersCount = membersCount
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.progressPercent = progressPercent
        self.status = status
        self.joinedAt = joinedAt
    }
}

extension ChallengeTeamModel {
    
    init(response: ChallengeTeamResponse) {
        self.init(
            id: response.teamID,
            challengeID: response.challengeID,
            chatID: response.chatID,
            teamName: response.teamName,
            teamAvatar: response.teamAvatar,
            membersCount: response.membersCount,
            currentValue: response.currentValue,
            targetValue: response.targetValue,
            progressPercent: response.progressPercent / 100,
            status: ChallengeParticipationStatus(rawValue: response.status),
            joinedAt: response.joinedAt
        )
    }
}
