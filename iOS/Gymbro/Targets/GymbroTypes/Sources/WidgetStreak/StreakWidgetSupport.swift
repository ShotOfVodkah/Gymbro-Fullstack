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

    public init(
        weeklyTarget: Int,
        weeklyProgress: Int,
        streakValue: Int,
        daysUntilBurn: Int
    ) {
        self.weeklyTarget = max(1, weeklyTarget)
        self.weeklyProgress = min(max(0, weeklyProgress), self.weeklyTarget)
        self.streakValue = max(0, streakValue)
        self.daysUntilBurn = max(0, daysUntilBurn)
    }

    public var progressRatio: Double {
        Double(weeklyProgress) / Double(max(weeklyTarget, 1))
    }

    public var isDangerState: Bool {
        daysUntilBurn <= 2 && weeklyProgress < weeklyTarget
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
