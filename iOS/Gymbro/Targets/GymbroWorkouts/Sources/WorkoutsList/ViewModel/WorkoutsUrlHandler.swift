import Foundation
import DivKit

extension WorkoutsNavigationLink {
    init?(url: URL) {
        guard url.scheme == "app" else { return nil }

        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = url.host ?? ""

        switch host {
        case "open_workout":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .openWorkout(id: id)
        case "open_builder":
            self = .openBuilder
        case "open_streak":
            let items = comps?.queryItems
            let current = Self.intQuery(items, name: "current")
            let goal = Self.intQuery(items, name: "goal")
            let total = Self.intQuery(items, name: "total")

            let weekEndDate = Self.parseWeekEndDate(from: items)
            let legacyDaysLeft = Self.intQuery(items, name: "daysLeft")
            let daysLeft: Int
            if let weekEndDate {
                daysLeft = Self.daysRemaining(until: weekEndDate)
            } else if let legacyDaysLeft {
                daysLeft = legacyDaysLeft
            } else {
                return nil
            }

            let freezeUsed = Self.boolQuery(items, name: "freezeUsed")
                || Self.boolQuery(items, name: "wasFreezeUsedThisWeek")
            let goalCompleted = Self.boolQuery(items, name: "goalCompleted")
                || Self.boolQuery(items, name: "isGoalCompleted")

            guard let current, let goal, let total else {
                return nil
            }

            self = .openStreak(
                current: current,
                goal: goal,
                daysLeft: daysLeft,
                value: total,
                wasFreezeUsedThisWeek: freezeUsed,
                isGoalCompleted: goalCompleted
            )
        default:
            return nil
        }
    }

    private static func intQuery(_ items: [URLQueryItem]?, name: String) -> Int? {
        items?.first(where: { $0.name == name })?.value.flatMap(Int.init)
    }

    private static func boolQuery(_ items: [URLQueryItem]?, name: String) -> Bool {
        guard let raw = items?.first(where: { $0.name == name })?.value?.lowercased() else {
            return false
        }
        return raw == "true" || raw == "1" || raw == "yes"
    }

    private static func parseWeekEndDate(from items: [URLQueryItem]?) -> Date? {
        guard let raw = items?.first(where: { $0.name == "weekEnd" })?.value,
              !raw.isEmpty
        else { return nil }

        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = fractional.date(from: raw) { return d }

        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: raw)
    }

    private static func daysRemaining(until weekEnd: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: weekEnd)
        return max(calendar.dateComponents([.day], from: start, to: end).day ?? 0, 0)
    }
}


final class WorkoutsDivUrlHandler: DivUrlHandler {
    private let handleNavigationLink: @MainActor (WorkoutsNavigationLink) -> Void


    init(handleNavigationLink: @escaping @MainActor (WorkoutsNavigationLink) -> Void) {
        self.handleNavigationLink = handleNavigationLink
    }


    func handle(_ url: URL, sender: AnyObject?) {
        guard let link = WorkoutsNavigationLink(url: url) else { return }
        Task { @MainActor in handleNavigationLink(link) }
    }
}
