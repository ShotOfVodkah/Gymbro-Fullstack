package models

type DataQualityDailyItem struct {
	EventDate                  string  `db:"event_date" json:"event_date"`
	AppVersion                 string  `db:"app_version" json:"app_version"`
	EventsReceived             int     `db:"events_received" json:"events_received"`
	EventsAccepted             int     `db:"events_accepted" json:"events_accepted"`
	EventsRejected             int     `db:"events_rejected" json:"events_rejected"`
	InvalidRate                float64 `db:"invalid_rate" json:"invalid_rate"`
	UnknownEventsCount         int     `db:"unknown_events_count" json:"unknown_events_count"`
	UnknownEventsRate          float64 `db:"unknown_events_rate" json:"unknown_events_rate"`
	MissingRequiredFieldsCount int     `db:"missing_required_fields_count" json:"missing_required_fields_count"`
}

type DataQualitySummaryResponse struct {
	Items []DataQualityDailyItem `json:"items"`
}

type DataQualityOverviewItem struct {
	EventDate                  string  `db:"event_date" json:"event_date"`
	EventsReceived             int     `db:"events_received" json:"events_received"`
	EventsAccepted             int     `db:"events_accepted" json:"events_accepted"`
	EventsRejected             int     `db:"events_rejected" json:"events_rejected"`
	InvalidRate                float64 `db:"invalid_rate" json:"invalid_rate"`
	UnknownEventsCount         int     `db:"unknown_events_count" json:"unknown_events_count"`
	UnknownEventsRate          float64 `db:"unknown_events_rate" json:"unknown_events_rate"`
	MissingRequiredFieldsCount int     `db:"missing_required_fields_count" json:"missing_required_fields_count"`
}

type DataQualityOverviewResponse struct {
	Item *DataQualityOverviewItem `json:"item"`
}