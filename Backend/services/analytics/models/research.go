package models

type ResearchGroupMetrics struct {
	GroupName               string  `db:"group_name" json:"group_name"`
	UsersCount              int     `db:"users_count" json:"users_count"`
	AverageActiveDaysLast7  float64 `db:"average_active_days_last_7" json:"average_active_days_last_7"`
	AverageActiveDaysLast30 float64 `db:"average_active_days_last_30" json:"average_active_days_last_30"`
	AverageSessionsCount    float64 `db:"average_sessions_count" json:"average_sessions_count"`
	AverageWorkoutEvents    float64 `db:"average_workout_events" json:"average_workout_events"`
	AverageSocialActions    float64 `db:"average_social_actions" json:"average_social_actions"`
	AverageErrorEvents      float64 `db:"average_error_events" json:"average_error_events"`
}

type ResearchComparisonResponse struct {
	Title  string                 `json:"title"`
	Groups []ResearchGroupMetrics `json:"groups"`
}

type ResearchFeatureRetentionItem struct {
	FeatureName              string  `db:"feature_name" json:"feature_name"`
	UsersCount               int     `db:"users_count" json:"users_count"`
	AverageActiveDaysLast7   float64 `db:"average_active_days_last_7" json:"average_active_days_last_7"`
	AverageActiveDaysLast30  float64 `db:"average_active_days_last_30" json:"average_active_days_last_30"`
	AverageSessionsCount     float64 `db:"average_sessions_count" json:"average_sessions_count"`
}

type ResearchFeatureRetentionResponse struct {
	Title string                         `json:"title"`
	Items []ResearchFeatureRetentionItem `json:"items"`
}