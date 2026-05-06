import Foundation

public extension StreakResponse {

    func daysRemainingInWeek(calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: weekEndDate)
        return max(calendar.dateComponents([.day], from: start, to: end).day ?? 0, 0)
    }

    func workoutsListStreakQueryItems(calendar: Calendar = .current) -> [URLQueryItem] {
        let daysLeft = daysRemainingInWeek(calendar: calendar)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let weekEndString = formatter.string(from: weekEndDate)
        return [
            URLQueryItem(name: "completedThisWeek", value: "\(completedThisWeek)"),
            URLQueryItem(name: "weeklyGoal", value: "\(weeklyGoal)"),
            URLQueryItem(name: "currentStreakWeeks", value: "\(currentStreakWeeks)"),
            URLQueryItem(name: "daysLeft", value: "\(daysLeft)"),
            URLQueryItem(name: "weekEnd", value: weekEndString),
            URLQueryItem(name: "wasFreezeUsedThisWeek", value: wasFreezeUsedThisWeek ? "true" : "false"),
            URLQueryItem(name: "isGoalCompleted", value: isGoalCompleted ? "true" : "false"),
        ]
    }
}
