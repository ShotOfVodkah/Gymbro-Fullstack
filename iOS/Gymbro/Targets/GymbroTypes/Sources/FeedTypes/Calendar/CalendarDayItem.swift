import Foundation

public struct CalendarDayItem: Identifiable, Hashable {
    public let id: UUID
    public let date: Date
    public let dayNumber: Int
    public let isInCurrentMonth: Bool
    
    public let hasMyWorkout: Bool
    public let myWorkoutID: String?
    
    public let hasPartnerWorkout: Bool
    public let partnerWorkoutID: String?
    
    public let isToday: Bool
    public let isSelected: Bool
    
    public init(
        id: UUID = UUID(),
        date: Date,
        dayNumber: Int,
        isInCurrentMonth: Bool,
        hasMyWorkout: Bool = false,
        myWorkoutID: String? = nil,
        hasPartnerWorkout: Bool = false,
        partnerWorkoutID: String? = nil,
        isToday: Bool = false,
        isSelected: Bool = false
    ) {
        self.id = id
        self.date = date
        self.dayNumber = dayNumber
        self.isInCurrentMonth = isInCurrentMonth
        self.hasMyWorkout = hasMyWorkout
        self.myWorkoutID = myWorkoutID
        self.hasPartnerWorkout = hasPartnerWorkout
        self.partnerWorkoutID = partnerWorkoutID
        self.isToday = isToday
        self.isSelected = isSelected
    }
}
