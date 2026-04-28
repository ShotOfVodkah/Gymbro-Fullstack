public enum PerksEventType: String {
    case workoutCompleted = "workout_completed"
    case workoutCreated = "workout_created"
    case workoutShared = "workout_shared"
    
    case postLiked = "post_liked"
    case postCommented = "post_commented"
    case commentCreated = "comment_created"
    
    case profileOpened = "profile_opened"
    
    case weeklyGoalUpdated = "weekly_goal_updated"
    case streakFreezeUsed = "streak_freeze_used"
}
