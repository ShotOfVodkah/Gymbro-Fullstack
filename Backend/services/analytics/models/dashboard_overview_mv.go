package models

type DashboardOverviewMVItem struct {
	EventDate               string  `db:"event_date" json:"event_date"`
	BatchesReceived         int     `db:"batches_received" json:"batches_received"`
	EventsReceived          int     `db:"events_received" json:"events_received"`
	EventsAccepted          int     `db:"events_accepted" json:"events_accepted"`
	EventsRejected          int     `db:"events_rejected" json:"events_rejected"`
	BacklogPending          int     `db:"backlog_pending" json:"backlog_pending"`
	BacklogProcessing       int     `db:"backlog_processing" json:"backlog_processing"`
	BacklogFailed           int     `db:"backlog_failed" json:"backlog_failed"`
	AvgProcessingLagSeconds float64 `db:"avg_processing_lag_seconds" json:"avg_processing_lag_seconds"`
	MaxProcessingLagSeconds float64 `db:"max_processing_lag_seconds" json:"max_processing_lag_seconds"`
	ProcessingFailures      int     `db:"processing_failures" json:"processing_failures"`
	DAU                     int     `db:"dau" json:"dau"`
	TotalErrors             int     `db:"total_errors" json:"total_errors"`
	InvalidRate             float64 `db:"invalid_rate" json:"invalid_rate"`
}