import Foundation

enum FeedsCalendarMockData {
    
    static let people: [CalendarPerson] = [
        CalendarPerson(id: "me", name: "You", avatarSystemName: "person.fill"),
        CalendarPerson(
            id: FeedsPeopleMockData.alex.id.uuidString,
            name: FeedsPeopleMockData.alex.name,
            avatarSystemName: FeedsPeopleMockData.alex.avatarSystemName
        ),
        CalendarPerson(
            id: FeedsPeopleMockData.maria.id.uuidString,
            name: FeedsPeopleMockData.maria.name,
            avatarSystemName: FeedsPeopleMockData.maria.avatarSystemName
        ),
        CalendarPerson(
            id: FeedsPeopleMockData.coachDaniel.id.uuidString,
            name: FeedsPeopleMockData.coachDaniel.name,
            avatarSystemName: FeedsPeopleMockData.coachDaniel.avatarSystemName
        ),
        CalendarPerson(
            id: FeedsPeopleMockData.lena.id.uuidString,
            name: FeedsPeopleMockData.lena.name,
            avatarSystemName: FeedsPeopleMockData.lena.avatarSystemName
        ),
        CalendarPerson(
            id: FeedsPeopleMockData.ivan.id.uuidString,
            name: FeedsPeopleMockData.ivan.name,
            avatarSystemName: FeedsPeopleMockData.ivan.avatarSystemName
        ),
        CalendarPerson(
            id: FeedsPeopleMockData.nina.id.uuidString,
            name: FeedsPeopleMockData.nina.name,
            avatarSystemName: FeedsPeopleMockData.nina.avatarSystemName
        )
    ]
    
    static let workoutsByPerson: [String: [Date: String]] = [
        "me": [
            mockDate(day: 3): "me_w1",
            mockDate(day: 6): "me_w2",
            mockDate(day: 12): "me_w3",
            mockDate(day: 19): "me_w4"
        ],
        
        FeedsPeopleMockData.alex.id.uuidString: [
            mockDate(day: 2): "alex_w1",
            mockDate(day: 6): "alex_w4",
            mockDate(day: 8): "alex_w2",
            mockDate(day: 17): "alex_w3"
        ],
        
        FeedsPeopleMockData.maria.id.uuidString: [
            mockDate(day: 5): "maria_w1",
            mockDate(day: 14): "maria_w2",
            mockDate(day: 22): "maria_w3"
        ],
        
        FeedsPeopleMockData.coachDaniel.id.uuidString: [
            mockDate(day: 4): "coach_w1",
            mockDate(day: 10): "coach_w2",
            mockDate(day: 21): "coach_w3"
        ],
        
        FeedsPeopleMockData.lena.id.uuidString: [
            mockDate(day: 7): "lena_w1",
            mockDate(day: 18): "lena_w2"
        ],
        
        FeedsPeopleMockData.ivan.id.uuidString: [
            mockDate(day: 9): "ivan_w1",
            mockDate(day: 15): "ivan_w2"
        ],
        
        FeedsPeopleMockData.nina.id.uuidString: [
            mockDate(day: 11): "nina_w1",
            mockDate(day: 24): "nina_w2"
        ]
    ]
    
    static func mockDate(day: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        let date = calendar.date(
            from: DateComponents(
                year: components.year,
                month: components.month,
                day: day
            )
        ) ?? now
        
        return calendar.startOfDay(for: date)
    }
}
