import Foundation

struct CalendarDayItem: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let dayNumber: Int
    let isInCurrentMonth: Bool
    
    let hasMyWorkout: Bool
    let myWorkoutID: String?
    
    let hasPartnerWorkout: Bool
    let partnerWorkoutID: String?
    
    let isToday: Bool
    let isSelected: Bool
    
    init(
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
