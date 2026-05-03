import Foundation

public struct ChallengeLeaderboardTeamModel: Identifiable, Hashable {
    public let id: String
    public let rank: Int
    public let teamID: String
    public let chatID: String
    public let teamName: String
    public let teamAvatar: String
    public let membersCount: Int
    public let currentValue: Int
    public let targetValue: Int
    public let progressPercent: Double
    public let status: ChallengeParticipationStatus
    public let isCurrentUserTeam: Bool
    
    public init(
        id: String,
        rank: Int,
        teamID: String,
        chatID: String,
        teamName: String,
        teamAvatar: String,
        membersCount: Int,
        currentValue: Int,
        targetValue: Int,
        progressPercent: Double,
        status: ChallengeParticipationStatus,
        isCurrentUserTeam: Bool
    ) {
        self.id = id
        self.rank = rank
        self.teamID = teamID
        self.chatID = chatID
        self.teamName = teamName
        self.teamAvatar = teamAvatar
        self.membersCount = membersCount
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.progressPercent = progressPercent
        self.status = status
        self.isCurrentUserTeam = isCurrentUserTeam
    }
}

extension ChallengeLeaderboardTeamModel {
    
    public init(response: ChallengeLeaderboardTeamResponse) {
        self.init(
            id: response.teamID,
            rank: response.rank,
            teamID: response.teamID,
            chatID: response.chatID,
            teamName: response.teamName,
            teamAvatar: response.teamAvatar ?? "person.3.fill",
            membersCount: response.membersCount,
            currentValue: response.currentValue,
            targetValue: response.targetValue,
            progressPercent: response.progressPercent / 100,
            status: ChallengeParticipationStatus(rawValue: response.status),
            isCurrentUserTeam: response.isCurrentUserTeam ?? false
        )
    }
}
