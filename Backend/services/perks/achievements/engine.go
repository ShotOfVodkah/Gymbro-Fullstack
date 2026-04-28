package achievements

type AchievementEngine struct {
	rules []AchievementRule
}

func NewAchievementEngine() *AchievementEngine {
	return &AchievementEngine{
		rules: []AchievementRule{
			// Milestones
			NewCounterRule("rookie", "workout_completed"),
			NewCounterRule("workouts_50", "workout_completed"),
			NewCounterRule("workouts_100", "workout_completed"),
			NewCounterRule("workouts_200", "workout_completed"),
			NewCounterRule("workouts_300", "workout_completed"),
			NewCounterRule("workouts_400", "workout_completed"),
			NewCounterRule("workouts_500", "workout_completed"),

			// Time challenges
			NewDayOfWeekRule("tough_day", "workout_completed", "monday"),
			NewWeekendRule("lazy_weekend", "workout_completed"),
			NewTimeBeforeRule("early_riser", "workout_completed", 7),
			NewTimeAfterRule("night_owl", "workout_completed", 23),
			NewExactTimeRule("cinderella", "workout_completed", "00:00"),

			// Consistency
			NewCounterRule("busy_week", "consecutive_workout_day"),
			NewCounterRule("consistent_start", "weekly_goal_completed"),
			NewCounterRule("fire_keeper", "streak_week_completed"),
			NewCounterRule("unstoppable", "streak_week_completed"),
			NewCounterRule("back_to_prime", "workout_after_missed_week"),
			NewCounterRule("locked_in", "monthly_workout_completed"),

			// Social
			NewCounterRule("gymbro", "workout_shared"),
			NewCounterRule("pornstar", "post_comment_received"),
			NewCounterRule("social_butterfly", "workout_shared"),
			NewCounterRule("first_like", "post_liked_received"),
			NewCounterRule("main_character_energy", "post_liked_received"),
			NewCounterRule("busybody", "profile_opened"),
			NewCounterRule("backseat_driver", "friend_workout_commented"),

			// Special
			NewCounterRule("less_words", "workout_without_notes"),
			NewCounterRule("whole_body", "workout_three_muscle_groups"),
			NewCounterRule("i_know_better", "custom_workout_created"),
		},
	}
}

func (e *AchievementEngine) Evaluate(
	event PerkEvent,
	currentProgress map[string]int,
	targetProgress map[string]int,
) []AchievementProgressUpdate {
	updates := make([]AchievementProgressUpdate, 0)

	for _, rule := range e.rules {
		if !rule.Applies(event) {
			continue
		}

		code := rule.Code()
		current := currentProgress[code]
		target := targetProgress[code]

		update := rule.Evaluate(event, current, target)
		updates = append(updates, update)
	}

	return updates
}