import Foundation

public struct CalendarPersonResponse: Decodable {
    let id: String
    let name: String
    let avatar_system_name: String
}

public struct CalendarWorkoutDayResponse: Decodable {
    public let date: String
    public let workout_id: String
}

public struct CalendarMonthResponse: Decodable {
    let month: String
    public let my_workouts: [CalendarWorkoutDayResponse]
    public let partner_workouts: [CalendarWorkoutDayResponse]
}
