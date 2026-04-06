import Foundation

struct CalendarDayItem: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let dayNumber: Int
    let isInCurrentMonth: Bool
    let hasWorkout: Bool
    let workoutID: String?
    let isToday: Bool
    let isSelected: Bool
    
    init(
        id: UUID = UUID(),
        date: Date,
        dayNumber: Int,
        isInCurrentMonth: Bool,
        hasWorkout: Bool,
        workoutID: String? = nil,
        isToday: Bool = false,
        isSelected: Bool = false
    ) {
        self.id = id
        self.date = date
        self.dayNumber = dayNumber
        self.isInCurrentMonth = isInCurrentMonth
        self.hasWorkout = hasWorkout
        self.workoutID = workoutID
        self.isToday = isToday
        self.isSelected = isSelected
    }
}
