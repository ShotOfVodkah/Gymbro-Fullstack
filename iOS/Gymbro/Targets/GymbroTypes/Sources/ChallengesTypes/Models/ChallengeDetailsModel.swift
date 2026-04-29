import Foundation

public struct ChallengeDetailsModel: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let iconName: String
    public let accentColorName: String
    public let status: ChallengeStatus
    public let participationStatus: ChallengeParticipationStatus
    public let difficulty: ChallengeDifficulty
    public let type: ChallengeType
    public let unit: ChallengeUnit
    public let startDate: Date
    public let endDate: Date
    public let currentValue: Int
    public let targetValue: Int
    public let progressPercent: Double
    public let progressText: String
    public let timeLeftText: String
    public let team: ChallengeTeamModel?
    public let participants: [ChallengeParticipantModel]
    public let rules: [ChallengeRulesModel]
    public let rewards: [ChallengeRewardModel]
    
    public init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        accentColorName: String,
        status: ChallengeStatus,
        participationStatus: ChallengeParticipationStatus,
        difficulty: ChallengeDifficulty,
        type: ChallengeType,
        unit: ChallengeUnit,
        startDate: Date,
        endDate: Date,
        currentValue: Int,
        targetValue: Int,
        progressPercent: Double,
        progressText: String,
        timeLeftText: String,
        team: ChallengeTeamModel?,
        participants: [ChallengeParticipantModel],
        rules: [ChallengeRulesModel],
        rewards: [ChallengeRewardModel]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.accentColorName = accentColorName
        self.status = status
        self.participationStatus = participationStatus
        self.difficulty = difficulty
        self.type = type
        self.unit = unit
        self.startDate = startDate
        self.endDate = endDate
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.progressPercent = progressPercent
        self.progressText = progressText
        self.timeLeftText = timeLeftText
        self.team = team
        self.participants = participants
        self.rules = rules
        self.rewards = rewards
    }
}

extension ChallengeDetailsModel {
    
    public init(response: ChallengeDetailsResponse) {
        let participationStatus = ChallengeParticipationStatus(rawValue: response.participationStatus)
        
        self.init(
            id: response.id,
            title: response.title,
            description: response.description,
            iconName: response.coverIcon,
            accentColorName: response.accentColor ?? participationStatus.colorName,
            status: ChallengeStatus(rawValue: response.status),
            participationStatus: participationStatus,
            difficulty: ChallengeDifficulty(rawValue: response.difficulty),
            type: ChallengeType(rawValue: response.type),
            unit: ChallengeUnit(rawValue: response.unit),
            startDate: response.startDate,
            endDate: response.endDate,
            currentValue: response.currentValue,
            targetValue: response.targetValue,
            progressPercent: response.progressPercent / 100,
            progressText: ChallengeFormatter.progressText(
                current: response.currentValue,
                target: response.targetValue,
                unit: response.unit
            ),
            timeLeftText: ChallengeFormatter.timeLeftText(endDate: response.endDate),
            team: response.team.map { ChallengeTeamModel(response: $0) },
            participants: response.participants.map { ChallengeParticipantModel(response: $0) },
            rules: response.rules.map { ChallengeRulesModel(text: $0) },
            rewards: response.rewards?.map { ChallengeRewardModel(response: $0) } ?? []
        )
    }
}
