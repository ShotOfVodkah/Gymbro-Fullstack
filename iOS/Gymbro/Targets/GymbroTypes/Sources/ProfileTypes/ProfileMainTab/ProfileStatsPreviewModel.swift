import Foundation

public struct ProfileStatsPreviewModel: Equatable, Hashable {
    public let workoutsThisMonth: Int
    public let totalWorkouts: Int
    public let totalHours: Int
    public let favoriteWorkoutType: String
    public let mostActiveWeekday: String
    public let consistencyPercent: Int
    
    public init(
        workoutsThisMonth: Int,
        totalWorkouts: Int,
        totalHours: Int,
        favoriteWorkoutType: String,
        mostActiveWeekday: String,
        consistencyPercent: Int
    ) {
        self.workoutsThisMonth = workoutsThisMonth
        self.totalWorkouts = totalWorkouts
        self.totalHours = totalHours
        self.favoriteWorkoutType = favoriteWorkoutType
        self.mostActiveWeekday = mostActiveWeekday
        self.consistencyPercent = consistencyPercent
    }
}
