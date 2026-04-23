package models

type FunnelDailyItem struct {
	EventDate            string  `db:"event_date" json:"event_date"`
	FunnelName           string  `db:"funnel_name" json:"funnel_name"`
	StepOrder            int     `db:"step_order" json:"step_order"`
	StepName             string  `db:"step_name" json:"step_name"`
	UsersCount           int     `db:"users_count" json:"users_count"`
	ConversionFromPrev   float64 `db:"conversion_from_prev" json:"conversion_from_prev"`
	ConversionFromStart  float64 `db:"conversion_from_start" json:"conversion_from_start"`
}

type FunnelResponse struct {
	FunnelName string            `json:"funnel_name"`
	EventDate  string            `json:"event_date"`
	Items      []FunnelDailyItem `json:"items"`
}