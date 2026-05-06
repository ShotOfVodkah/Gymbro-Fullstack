import WidgetKit

import GymbroTypes

struct StreakWidgetEntry: TimelineEntry {
    let date: Date
    let payload: StreakWidgetPayload
}

struct StreakWidgetProvider: TimelineProvider {
    private let store = StreakWidgetStore()

    private static var emptyPayload: StreakWidgetPayload {
        StreakWidgetPayload(
            weeklyTarget: 1,
            weeklyProgress: 0,
            streakValue: 0,
            daysUntilBurn: 0,
            wasFreezeUsedThisWeek: false,
            isGoalCompleted: false
        )
    }

    func placeholder(in context: Context) -> StreakWidgetEntry {
        StreakWidgetEntry(date: Date(), payload: Self.emptyPayload)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakWidgetEntry) -> Void) {
        let payload = store.load() ?? Self.emptyPayload
        completion(StreakWidgetEntry(date: Date(), payload: payload))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakWidgetEntry>) -> Void) {
        let payload = store.load() ?? Self.emptyPayload
        let entry = StreakWidgetEntry(date: Date(), payload: payload)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}
