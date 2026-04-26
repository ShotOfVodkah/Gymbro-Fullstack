import Foundation

public enum ActivityCalendarWidgetConfig {
    public static let appGroupID = "group.dev.tuist.Gymbro"
    public static let payloadKey = "activity_calendar_widget_payload"
    public static let kind = "GymbroActivityCalendarWidget"
}

public struct ActivityCalendarWidgetPayload: Codable, Equatable {
    public let month: String
    public let workoutDays: [Int]

    public init(month: String, workoutDays: [Int]) {
        self.month = month
        self.workoutDays = workoutDays
    }

    public init(response: CalendarMonthResponse) {
        self.month = response.month
        var dayNumbers: Set<Int> = []
        for item in response.my_workouts {
            let parts = item.date.split(separator: "-")
            guard parts.count == 3,
                  String(parts[0] + "-" + parts[1]) == response.month,
                  let day = Int(parts[2])
            else {
                continue
            }
            if (1...31).contains(day) {
                dayNumbers.insert(day)
            }
        }
        self.workoutDays = dayNumbers.sorted()
    }
}

public final class ActivityCalendarWidgetStore {
    public init(
        suiteName: String = ActivityCalendarWidgetConfig.appGroupID,
        payloadKey: String = ActivityCalendarWidgetConfig.payloadKey
    ) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        self.payloadKey = payloadKey
    }

    public func save(_ payload: ActivityCalendarWidgetPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        defaults.set(data, forKey: payloadKey)
    }

    public func load() -> ActivityCalendarWidgetPayload? {
        guard let data = defaults.data(forKey: payloadKey) else { return nil }
        return try? JSONDecoder().decode(ActivityCalendarWidgetPayload.self, from: data)
    }

    private let defaults: UserDefaults
    private let payloadKey: String
}

public protocol ActivityCalendarWidgetTimelineReloading: AnyObject {
    func reloadActivityCalendarWidgetTimelines()
}

public protocol ActivityCalendarWidgetControlling: AnyObject {
    func applySnapshot(with payload: ActivityCalendarWidgetPayload) async
}
