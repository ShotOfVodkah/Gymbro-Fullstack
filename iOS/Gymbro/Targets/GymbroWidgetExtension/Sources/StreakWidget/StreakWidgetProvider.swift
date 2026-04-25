import WidgetKit

import GymbroTypes

struct StreakWidgetEntry: TimelineEntry {
    let date: Date
    let payload: StreakWidgetPayload
}

struct StreakWidgetProvider: TimelineProvider {
    private let store = StreakWidgetStore()

    func placeholder(in context: Context) -> StreakWidgetEntry {
        StreakWidgetEntry(
            date: Date(),
            payload: StreakWidgetPayload(
                weeklyTarget: 0,
                weeklyProgress: 0,
                streakValue: 0,
                daysUntilBurn: 0
            ))
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakWidgetEntry) -> Void) {
        guard let payload = store.load() else { return }
        completion(StreakWidgetEntry(date: Date(), payload: payload))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakWidgetEntry>) -> Void) {
        guard let payload = store.load() else { return }
        let entry = StreakWidgetEntry(date: Date(), payload: payload)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}
