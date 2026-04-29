import Foundation

public enum ChallengeType: String, Codable, Hashable {
    case teamWorkoutsCount = "team_workouts_count"
    case teamTrainingMinutes = "team_training_minutes"
    case teamCaloriesBurned = "team_calories_burned"
    case teamStreakDays = "team_streak_days"
    case individualContribution = "individual_contribution"
    case workoutCategory = "workout_category"
    
    public init(rawValue: String) {
        switch rawValue {
        case "team_workouts_count": self = .teamWorkoutsCount
        case "team_training_minutes": self = .teamTrainingMinutes
        case "team_calories_burned": self = .teamCaloriesBurned
        case "team_streak_days": self = .teamStreakDays
        case "individual_contribution": self = .individualContribution
        case "workout_category": self = .workoutCategory
        default: self = .teamWorkoutsCount
        }
    }
}
