import Foundation

public struct ChallengeCardModel: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let iconName: String
    public let accentColorName: String
    public let status: ChallengeParticipationStatus
    public let difficulty: ChallengeDifficulty
    public let type: ChallengeType
    public let unit: ChallengeUnit
    public let progressText: String
    public let progressPercent: Double
    public let dateText: String
    public let teamName: String?
    public let membersCount: Int?
    public let isJoined: Bool
    
    public init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        accentColorName: String,
        status: ChallengeParticipationStatus,
        difficulty: ChallengeDifficulty,
        type: ChallengeType,
        unit: ChallengeUnit,
        progressText: String,
        progressPercent: Double,
        dateText: String,
        teamName: String?,
        membersCount: Int?,
        isJoined: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.accentColorName = accentColorName
        self.status = status
        self.difficulty = difficulty
        self.type = type
        self.unit = unit
        self.progressText = progressText
        self.progressPercent = progressPercent
        self.dateText = dateText
        self.teamName = teamName
        self.membersCount = membersCount
        self.isJoined = isJoined
    }
}

extension ChallengeCardModel {
    
    public init(response: ChallengeResponse) {
        let participationStatus = ChallengeParticipationStatus(rawValue: response.participationStatus)
        
        self.init(
            id: response.id,
            title: response.title,
            description: response.description,
            iconName: response.coverIcon,
            accentColorName: response.accentColor ?? participationStatus.colorName,
            status: participationStatus,
            difficulty: ChallengeDifficulty(rawValue: response.difficulty),
            type: ChallengeType(rawValue: response.type),
            unit: ChallengeUnit(rawValue: response.unit),
            progressText: ChallengeFormatter.progressText(
                current: response.currentValue,
                target: response.targetValue,
                unit: response.unit
            ),
            progressPercent: response.progressPercent / 100,
            dateText: ChallengeFormatter.timeLeftText(endDate: response.endDate),
            teamName: response.team?.teamName,
            membersCount: nil,
            isJoined: response.team != nil
        )
    }
}
