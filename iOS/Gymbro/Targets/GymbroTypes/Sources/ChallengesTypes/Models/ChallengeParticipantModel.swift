import Foundation

public struct ChallengeParticipantModel: Identifiable, Hashable {
    public var id: String { String(userID) }
    
    public let userID: Int
    public let name: String
    public let avatarSystemName: String
    public let contributionValue: Int
    public let contributionUnit: ChallengeUnit
    public let rankInTeam: Int
    public let lastActivityAt: Date?
    public let isMVP: Bool
    
    public init(
        userID: Int,
        name: String,
        avatarSystemName: String,
        contributionValue: Int,
        contributionUnit: ChallengeUnit,
        rankInTeam: Int,
        lastActivityAt: Date?,
        isMVP: Bool
    ) {
        self.userID = userID
        self.name = name
        self.avatarSystemName = avatarSystemName
        self.contributionValue = contributionValue
        self.contributionUnit = contributionUnit
        self.rankInTeam = rankInTeam
        self.lastActivityAt = lastActivityAt
        self.isMVP = isMVP
    }
}

extension ChallengeParticipantModel {
    
    init(response: ChallengeParticipantResponse) {
        self.init(
            userID: response.userID,
            name: response.name,
            avatarSystemName: response.avatarSystemName,
            contributionValue: response.contributionValue,
            contributionUnit: ChallengeUnit(rawValue: response.contributionUnit),
            rankInTeam: response.rankInTeam,
            lastActivityAt: response.lastActivityAt,
            isMVP: response.isMVP ?? (response.rankInTeam == 1)
        )
    }
}
