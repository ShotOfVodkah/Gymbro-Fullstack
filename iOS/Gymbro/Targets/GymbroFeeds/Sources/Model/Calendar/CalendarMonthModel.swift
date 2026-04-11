import Foundation

struct CalendarMonthModel: Hashable {
    let monthDate: Date
    let title: String
    let days: [CalendarDayItem]
    
    init(
        monthDate: Date,
        title: String,
        days: [CalendarDayItem]
    ) {
        self.monthDate = monthDate
        self.title = title
        self.days = days
    }
}
