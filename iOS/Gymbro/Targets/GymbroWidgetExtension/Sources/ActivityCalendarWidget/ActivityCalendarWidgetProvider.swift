import Foundation
import WidgetKit

import GymbroTypes

struct ActivityCalendarWidgetEntry: TimelineEntry {
    let date: Date
    let payload: ActivityCalendarWidgetPayload
}

struct ActivityCalendarWidgetProvider: TimelineProvider {
    private let store = ActivityCalendarWidgetStore()

    static func makePlaceholderPayload() -> ActivityCalendarWidgetPayload {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.timeZone = .current
        return ActivityCalendarWidgetPayload(
            month: f.string(from: Date()),
            workoutDays: [1, 3, 7, 12, 18, 25]
        )
    }

    static func makeEmptyPayloadForCurrentMonth() -> ActivityCalendarWidgetPayload {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.timeZone = .current
        return ActivityCalendarWidgetPayload(month: f.string(from: Date()), workoutDays: [])
    }

    func placeholder(in context: Context) -> ActivityCalendarWidgetEntry {
        ActivityCalendarWidgetEntry(
            date: Date(),
            payload: Self.makePlaceholderPayload()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ActivityCalendarWidgetEntry) -> Void) {
        let payload = store.load() ?? Self.makeEmptyPayloadForCurrentMonth()
        completion(ActivityCalendarWidgetEntry(date: Date(), payload: payload))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ActivityCalendarWidgetEntry>) -> Void) {
        let payload = store.load() ?? Self.makeEmptyPayloadForCurrentMonth()
        let entry = ActivityCalendarWidgetEntry(date: Date(), payload: payload)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}
