package models

type FeatureUsageDailyItem struct {
	EventDate   string `db:"event_date" json:"event_date"`
	FeatureName string `db:"feature_name" json:"feature_name"`
	TotalCount  int    `db:"total_count" json:"total_count"`
	UniqueUsers int    `db:"unique_users" json:"unique_users"`
}

type FeatureUsageResponse struct {
	Items []FeatureUsageDailyItem `json:"items"`
}