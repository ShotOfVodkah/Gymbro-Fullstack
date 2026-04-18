import Foundation

public struct StatisticsSummaryResponse: Decodable, Hashable {
    public let total_workouts: Int
    public let total_duration_hours: Int
    public let consistency: Int
    public let workouts_this_week: Int
    public let workouts_this_month: Int
    public let average_workout_duration_minutes: Int
    public let completion_rate: Int
    public let favorite_muscle_group: String
    public let most_active_day: String
    
    public init(
        total_workouts: Int,
        total_duration_hours: Int,
        consistency: Int,
        workouts_this_week: Int,
        workouts_this_month: Int,
        average_workout_duration_minutes: Int,
        completion_rate: Int,
        favorite_muscle_group: String,
        most_active_day: String
    ) {
        self.total_workouts = total_workouts
        self.total_duration_hours = total_duration_hours
        self.consistency = consistency
        self.workouts_this_week = workouts_this_week
        self.workouts_this_month = workouts_this_month
        self.average_workout_duration_minutes = average_workout_duration_minutes
        self.completion_rate = completion_rate
        self.favorite_muscle_group = favorite_muscle_group
        self.most_active_day = most_active_day
    }
}
