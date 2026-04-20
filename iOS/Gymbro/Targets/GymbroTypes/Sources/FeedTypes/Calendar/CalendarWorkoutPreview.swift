import Foundation

public struct CalendarWorkoutPreview: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let category: String
    public let durationMinutes: Int
    public let completedAt: Date
    public let timeLabel: String
    
    public init(
        id: String,
        title: String,
        category: String,
        durationMinutes: Int,
        completedAt: Date,
        timeLabel: String
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.durationMinutes = durationMinutes
        self.completedAt = completedAt
        self.timeLabel = timeLabel
    }
}

extension CalendarWorkoutPreview {
    public init?(response: CalendarWorkoutDayResponse) {
        let formatter = ISO8601DateFormatter()
        guard let completedAtDate = formatter.date(from: response.completed_at) else { return nil }
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        
        self.init(
            id: response.workout_id,
            title: response.title,
            category: response.category,
            durationMinutes: response.duration_minutes,
            completedAt: completedAtDate,
            timeLabel: timeFormatter.string(from: completedAtDate)
        )
    }
}
