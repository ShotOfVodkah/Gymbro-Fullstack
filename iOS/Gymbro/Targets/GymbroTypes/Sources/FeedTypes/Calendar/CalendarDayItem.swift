import Foundation

public struct CalendarDayItem: Identifiable, Hashable {
    public let id: UUID
    public let date: Date
    public let dayNumber: Int
    public let isInCurrentMonth: Bool
    
    public var hasMyWorkout: Bool { !myWorkouts.isEmpty }
    public let myWorkouts: [CalendarWorkoutPreview]
    
    public var hasPartnerWorkout: Bool { !partnerWorkouts.isEmpty }
    public let partnerWorkouts: [CalendarWorkoutPreview]
    
    public let isToday: Bool
    public let isSelected: Bool
    
    public init(
        id: UUID = UUID(),
        date: Date,
        dayNumber: Int,
        isInCurrentMonth: Bool,
        myWorkouts: [CalendarWorkoutPreview],
        partnerWorkouts: [CalendarWorkoutPreview],
        isToday: Bool = false,
        isSelected: Bool = false
    ) {
        self.id = id
        self.date = date
        self.dayNumber = dayNumber
        self.isInCurrentMonth = isInCurrentMonth
        self.myWorkouts = myWorkouts
        self.partnerWorkouts = partnerWorkouts
        self.isToday = isToday
        self.isSelected = isSelected
    }
}
