import Foundation

public struct ChallengeActivityModel: Identifiable, Hashable {
    public let id: String
    public let userID: Int
    public let userName: String
    public let avatarSystemName: String
    public let action: ChallengeActivityAction
    public let value: Int
    public let unit: ChallengeUnit
    public let sourceID: String?
    public let createdAt: Date
    
    public init(
        id: String,
        userID: Int,
        userName: String,
        avatarSystemName: String,
        action: ChallengeActivityAction,
        value: Int,
        unit: ChallengeUnit,
        sourceID: String?,
        createdAt: Date
    ) {
        self.id = id
        self.userID = userID
        self.userName = userName
        self.avatarSystemName = avatarSystemName
        self.action = action
        self.value = value
        self.unit = unit
        self.sourceID = sourceID
        self.createdAt = createdAt
    }
}

extension ChallengeActivityModel {
    
    public init(response: ChallengeActivityResponse) {
        self.init(
            id: response.id,
            userID: response.userID,
            userName: response.userName,
            avatarSystemName: response.avatarSystemName,
            action: ChallengeActivityAction(rawValue: response.action),
            value: response.value,
            unit: ChallengeUnit(rawValue: response.unit),
            sourceID: response.sourceID,
            createdAt: response.createdAt
        )
    }
}
