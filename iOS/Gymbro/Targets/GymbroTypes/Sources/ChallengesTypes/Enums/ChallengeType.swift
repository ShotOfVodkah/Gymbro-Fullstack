import Foundation

public enum ChallengeType: String, Codable, Hashable {
    case teamWorkoutsCount = "team_workouts_count"
    case teamTrainingMinutes = "team_training_minutes"
    case teamCaloriesBurned = "team_calories_burned"
    case teamStreakDays = "team_streak_days"
    case individualContribution = "individual_contribution"
    case workoutCategory = "workout_category"
    case exerciseSpecific = "exercise_specific"
    case muscleGroup = "muscle_group"
    
    public init(rawValue: String) {
        switch rawValue {
        case "team_workouts_count": self = .teamWorkoutsCount
        case "team_training_minutes": self = .teamTrainingMinutes
        case "team_calories_burned": self = .teamCaloriesBurned
        case "team_streak_days": self = .teamStreakDays
        case "individual_contribution": self = .individualContribution
        case "workout_category": self = .workoutCategory
        case "exercise_specific": self = .exerciseSpecific
        case "muscle_group": self = .muscleGroup
        default: self = .teamWorkoutsCount
        }
    }
}

public extension ChallengeType {
    
    var title: String {
        switch self {
        case .teamWorkoutsCount:
            return "Workouts"
        case .teamTrainingMinutes:
            return "Minutes"
        case .teamCaloriesBurned:
            return "Calories"
        case .teamStreakDays:
            return "Streak"
        case .individualContribution:
            return "Contribution"
        case .workoutCategory:
            return "Category"
        case .exerciseSpecific:
            return "Exercise"
        case .muscleGroup:
            return "Muscle Group"
        }
    }
    
    var iconName: String {
        switch self {
        case .teamWorkoutsCount:
            return "figure.strengthtraining.traditional"
        case .teamTrainingMinutes:
            return "clock.fill"
        case .teamCaloriesBurned:
            return "flame.fill"
        case .teamStreakDays:
            return "calendar.badge.clock"
        case .individualContribution:
            return "person.fill.checkmark"
        case .workoutCategory:
            return "square.grid.2x2.fill"
        case .exerciseSpecific:
            return "figure.strengthtraining.traditional"
        case .muscleGroup:
            return "figure.highintensity.intervaltraining"
        }
    }
}
