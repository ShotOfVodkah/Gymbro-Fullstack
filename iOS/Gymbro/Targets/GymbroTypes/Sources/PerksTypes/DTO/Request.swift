import Foundation

public struct UpdateWeeklyGoalRequest: Encodable, Sendable {
    public let weeklyGoal: Int
    
    public init(weeklyGoal: Int) {
        self.weeklyGoal = weeklyGoal
    }
}

public struct UseStreakFreezeRequest: Encodable, Sendable {
    public init() {}
}

public struct PerksEventRequest: Encodable, Sendable {
    public let type: String
    public let metadata: [String: String]
    public let createdAt: Date
    
    public init(
        type: String,
        metadata: [String: String],
        createdAt: Date
    ) {
        self.type = type
        self.metadata = metadata
        self.createdAt = createdAt
    }
}
