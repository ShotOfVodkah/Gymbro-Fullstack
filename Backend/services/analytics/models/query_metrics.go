package models

type OverviewMetricItem struct {
	Name        string `db:"name" json:"name"`
	Count       int    `db:"count" json:"count"`
	UniqueUsers int    `db:"unique_users" json:"unique_users"`
}

type OverviewResponse struct {
	ActiveUsersToday int                  `json:"active_users_today"`
	ActiveUsersTotal int                  `json:"active_users_total"`
	TotalEventsToday int                  `json:"total_events_today"`
	TotalErrorsToday int                  `json:"total_errors_today"`
	ErrorRateToday   float64              `json:"error_rate_today"`
	TopScreens       []OverviewMetricItem `json:"top_screens"`
	TopEvents        []OverviewMetricItem `json:"top_events"`
}

type ErrorMetricItem struct {
	Screen      string  `db:"screen" json:"screen"`
	ErrorCount  int     `db:"error_count" json:"error_count"`
	UniqueUsers int     `db:"unique_users" json:"unique_users"`
	RetryCount  int     `db:"retry_count" json:"retry_count"`
	RetryRate   float64 `db:"retry_rate" json:"retry_rate"`
}

type ErrorsResponse struct {
	Items []ErrorMetricItem `json:"items"`
}

type ScreenMetricItem struct {
	Screen        string  `db:"screen" json:"screen"`
	ViewsCount    int     `db:"views_count" json:"views_count"`
	UniqueUsers   int     `db:"unique_users" json:"unique_users"`
	ErrorCount    int     `db:"error_count" json:"error_count"`
	RetryCount    int     `db:"retry_count" json:"retry_count"`
	ErrorRate     float64 `db:"error_rate" json:"error_rate"`
	RetryRate     float64 `db:"retry_rate" json:"retry_rate"`
}

type ScreensResponse struct {
	Items []ScreenMetricItem `json:"items"`
}

type TopEventItem struct {
	EventName   string `db:"event_name" json:"event_name"`
	TotalCount  int    `db:"total_count" json:"total_count"`
	UniqueUsers int    `db:"unique_users" json:"unique_users"`
}

type TopEventsResponse struct {
	Items []TopEventItem `json:"items"`
}