import Foundation

enum FeedsCalendarMockData {
    
    static let people: [CalendarPerson] = [
        CalendarPerson(id: "me", name: "You", avatarSystemName: "person.fill"),
        CalendarPerson(id: "alex", name: "Alex", avatarSystemName: "figure.run"),
        CalendarPerson(id: "maria", name: "Maria", avatarSystemName: "figure.cooldown")
    ]
    
    static let workoutsByPerson: [String: [Date: String]] = [
        "me": [
            mockDate(day: 3): "w1",
            mockDate(day: 6): "w2",
            mockDate(day: 12): "w3",
            mockDate(day: 19): "w4"
        ],
        "alex": [
            mockDate(day: 2): "a1",
            mockDate(day: 8): "a2",
            mockDate(day: 17): "a3"
        ],
        "maria": [
            mockDate(day: 5): "m1",
            mockDate(day: 14): "m2",
            mockDate(day: 22): "m3"
        ]
    ]
    
    static func mockDate(day: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        return calendar.date(from: DateComponents(year: components.year, month: components.month, day: day)) ?? now
    }
}

