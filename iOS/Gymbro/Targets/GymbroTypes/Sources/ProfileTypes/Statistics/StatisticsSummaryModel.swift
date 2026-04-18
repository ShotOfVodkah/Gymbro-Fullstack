import Foundation

public struct StatisticsSummaryModel: Equatable, Hashable {
    public let totalWorkouts: Int
    public let totalDurationHours: Int
    public let consistency: Int
    public let workoutsThisWeek: Int
    public let workoutsThisMonth: Int
    public let averageWorkoutDurationMinutes: Int
    public let completionRate: Int
    public let favoriteMuscleGroup: String
    public let mostActiveDay: String
    
    public init(
        totalWorkouts: Int,
        totalDurationHours: Int,
        consistency: Int,
        workoutsThisWeek: Int,
        workoutsThisMonth: Int,
        averageWorkoutDurationMinutes: Int,
        completionRate: Int,
        favoriteMuscleGroup: String,
        mostActiveDay: String
    ) {
        self.totalWorkouts = totalWorkouts
        self.totalDurationHours = totalDurationHours
        self.consistency = consistency
        self.workoutsThisWeek = workoutsThisWeek
        self.workoutsThisMonth = workoutsThisMonth
        self.averageWorkoutDurationMinutes = averageWorkoutDurationMinutes
        self.completionRate = completionRate
        self.favoriteMuscleGroup = favoriteMuscleGroup
        self.mostActiveDay = mostActiveDay
    }
}
