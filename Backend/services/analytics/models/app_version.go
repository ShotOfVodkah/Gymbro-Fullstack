package models

type AppVersionDailyItem struct {
	EventDate               string  `db:"event_date" json:"event_date"`
	AppVersion              string  `db:"app_version" json:"app_version"`
	TotalEvents             int     `db:"total_events" json:"total_events"`
	UniqueUsers             int     `db:"unique_users" json:"unique_users"`
	ErrorCount              int     `db:"error_count" json:"error_count"`
	ErrorRate               float64 `db:"error_rate" json:"error_rate"`
	WorkoutShareOpenedUsers int     `db:"workout_share_opened_users" json:"workout_share_opened_users"`
	WorkoutShareDoneUsers   int     `db:"workout_share_done_users" json:"workout_share_done_users"`
	WorkoutShareConversion  float64 `db:"workout_share_conversion" json:"workout_share_conversion"`
}

type AppVersionsResponse struct {
	Items []AppVersionDailyItem `json:"items"`
}