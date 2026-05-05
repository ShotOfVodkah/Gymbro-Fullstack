import Foundation

public struct CalendarPersonResponse: Decodable {
    let id: String
    let name: String
    let avatar_system_name: String
}

public struct CalendarWorkoutDayResponse: Decodable {
    public let date: String
    let workout_id: String
    let title: String
    let category: String
    let duration_minutes: Int
    let completed_at: String
}

public struct CalendarMonthResponse: Decodable {
    public let month: String
    public let my_workouts: [CalendarWorkoutDayResponse]
    public let partner_workouts: [CalendarWorkoutDayResponse]
    
    enum CodingKeys: String, CodingKey {
        case month
        case my_workouts
        case partner_workouts
    }
    
    public init(
        month: String,
        my_workouts: [CalendarWorkoutDayResponse],
        partner_workouts: [CalendarWorkoutDayResponse]
    ) {
        self.month = month
        self.my_workouts = my_workouts
        self.partner_workouts = partner_workouts
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.month = try container.decode(String.self, forKey: .month)
        self.my_workouts = try container.decodeIfPresent([CalendarWorkoutDayResponse].self, forKey: .my_workouts) ?? []
        self.partner_workouts = try container.decodeIfPresent([CalendarWorkoutDayResponse].self, forKey: .partner_workouts) ?? []
    }
}
