import Foundation

public enum StreakWidgetConfig {
    public static let appGroupID = "group.dev.tuist.Gymbro"
    public static let payloadKey = "streak_widget_payload"
    public static let kind = "GymbroStreakWidget"
}

public struct StreakWidgetPayload: Codable, Equatable {
    public let weeklyTarget: Int
    public let weeklyProgress: Int
    public let streakValue: Int
    public let daysUntilBurn: Int
    public let wasFreezeUsedThisWeek: Bool
    public let isGoalCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case weeklyTarget
        case weeklyProgress
        case streakValue
        case daysUntilBurn
        case wasFreezeUsedThisWeek
        case isGoalCompleted
    }

    public init(
        weeklyTarget: Int,
        weeklyProgress: Int,
        streakValue: Int,
        daysUntilBurn: Int,
        wasFreezeUsedThisWeek: Bool = false,
        isGoalCompleted: Bool = false
    ) {
        self.weeklyTarget = max(1, weeklyTarget)
        self.weeklyProgress = min(max(0, weeklyProgress), self.weeklyTarget)
        self.streakValue = max(0, streakValue)
        self.daysUntilBurn = max(0, daysUntilBurn)
        self.wasFreezeUsedThisWeek = wasFreezeUsedThisWeek
        self.isGoalCompleted = isGoalCompleted
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let decodedTarget = try c.decode(Int.self, forKey: .weeklyTarget)
        weeklyTarget = max(1, decodedTarget)
        let rawProgress = try c.decode(Int.self, forKey: .weeklyProgress)
        weeklyProgress = min(max(0, rawProgress), weeklyTarget)
        streakValue = max(0, try c.decode(Int.self, forKey: .streakValue))
        daysUntilBurn = max(0, try c.decode(Int.self, forKey: .daysUntilBurn))
        wasFreezeUsedThisWeek = try c.decodeIfPresent(Bool.self, forKey: .wasFreezeUsedThisWeek) ?? false
        isGoalCompleted = try c.decodeIfPresent(Bool.self, forKey: .isGoalCompleted) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(weeklyTarget, forKey: .weeklyTarget)
        try c.encode(weeklyProgress, forKey: .weeklyProgress)
        try c.encode(streakValue, forKey: .streakValue)
        try c.encode(daysUntilBurn, forKey: .daysUntilBurn)
        try c.encode(wasFreezeUsedThisWeek, forKey: .wasFreezeUsedThisWeek)
        try c.encode(isGoalCompleted, forKey: .isGoalCompleted)
    }

    public var progressRatio: Double {
        Double(weeklyProgress) / Double(max(weeklyTarget, 1))
    }

    /// Matches `WeeklyStreakCardView.isDangerState` on Perks.
    public var isDangerState: Bool {
        !isGoalCompleted && !wasFreezeUsedThisWeek && daysUntilBurn <= 2 && weeklyProgress < weeklyTarget
    }
}

public extension StreakWidgetPayload {
    static func from(streak: StreakResponse, calendar: Calendar = .current) -> StreakWidgetPayload {
        StreakWidgetPayload(
            weeklyTarget: max(1, streak.weeklyGoal),
            weeklyProgress: streak.completedThisWeek,
            streakValue: streak.currentStreakWeeks,
            daysUntilBurn: streak.daysRemainingInWeek(calendar: calendar),
            wasFreezeUsedThisWeek: streak.wasFreezeUsedThisWeek,
            isGoalCompleted: streak.isGoalCompleted
        )
    }
}

public final class StreakWidgetStore {
    public init(
        suiteName: String = StreakWidgetConfig.appGroupID,
        payloadKey: String = StreakWidgetConfig.payloadKey
    ) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        self.payloadKey = payloadKey
    }

    public func save(_ payload: StreakWidgetPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        defaults.set(data, forKey: payloadKey)
    }

    public func load() -> StreakWidgetPayload? {
        guard let data = defaults.data(forKey: payloadKey) else { return nil }
        return try? JSONDecoder().decode(StreakWidgetPayload.self, from: data)
    }

    public func clear() {
        defaults.removeObject(forKey: payloadKey)
    }

    private let defaults: UserDefaults
    private let payloadKey: String
}

public protocol StreakWidgetTimelineReloading: AnyObject {
    func reloadStreakWidgetTimelines()
}

public protocol StreakWidgetControlling: AnyObject {
    func applySnapshotFromWorkoutsListLoaded(with payload: StreakWidgetPayload) async
    func incrementAfterSessionSuccessfullyCreated() async
}
