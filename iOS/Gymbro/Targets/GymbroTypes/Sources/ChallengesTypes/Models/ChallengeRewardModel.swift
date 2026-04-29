import Foundation

public struct ChallengeRewardModel: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let iconName: String
    public let isUnlocked: Bool
    
    public init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        isUnlocked: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.isUnlocked = isUnlocked
    }
}

extension ChallengeRewardModel {
    
    init(response: ChallengeRewardResponse) {
        self.init(
            id: response.id,
            title: response.title,
            description: response.description,
            iconName: response.iconName,
            isUnlocked: response.isUnlocked
        )
    }
}
