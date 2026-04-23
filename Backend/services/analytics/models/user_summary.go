package models

type UserSummaryItem struct {
	UserID              int64 `db:"user_id" json:"user_id"`
	ActiveDaysLast7     int   `db:"active_days_last_7" json:"active_days_last_7"`
	ActiveDaysLast30    int   `db:"active_days_last_30" json:"active_days_last_30"`
	SessionsCount       int   `db:"sessions_count" json:"sessions_count"`
	WorkoutEventsCount  int   `db:"workout_events_count" json:"workout_events_count"`
	SocialActionsCount  int   `db:"social_actions_count" json:"social_actions_count"`
	ErrorEventsCount    int   `db:"error_events_count" json:"error_events_count"`
}

type UserSummaryResponse struct {
	Item *UserSummaryItem `json:"item"`
}