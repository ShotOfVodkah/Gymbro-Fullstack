import Foundation

public struct ProfileMainResponse: Decodable, Hashable {
    public let user_id: Int
    public let name: String
    public let username: String
    public let status: String
    public let subtitle: String
    public let bio: String
    public let avatar_system_name: String
    public let badge: String?
    
    public let is_following: Bool?
    
    public let workouts_this_month: Int
    public let total_workouts: Int
    public let total_hours: Int
    public let favorite_workout_type: String
    public let most_active_weekday: String
    public let consistency_percent: Int
    
    public let weekly_activity: [ProfileWeeklyActivityResponse]
    
    public init(
        user_id: Int,
        name: String,
        username: String,
        status: String,
        subtitle: String,
        bio: String,
        avatar_system_name: String,
        badge: String?,
        is_following: Bool?,
        workouts_this_month: Int,
        total_workouts: Int,
        total_hours: Int,
        favorite_workout_type: String,
        most_active_weekday: String,
        consistency_percent: Int,
        weekly_activity: [ProfileWeeklyActivityResponse]
    ) {
        self.user_id = user_id
        self.name = name
        self.username = username
        self.status = status
        self.subtitle = subtitle
        self.bio = bio
        self.avatar_system_name = avatar_system_name
        self.badge = badge
        self.is_following = is_following
        self.workouts_this_month = workouts_this_month
        self.total_workouts = total_workouts
        self.total_hours = total_hours
        self.favorite_workout_type = favorite_workout_type
        self.most_active_weekday = most_active_weekday
        self.consistency_percent = consistency_percent
        self.weekly_activity = weekly_activity
    }
}
