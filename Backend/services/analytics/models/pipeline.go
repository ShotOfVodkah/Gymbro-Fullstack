package models

type PipelineOverviewItem struct {
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
}

type PipelineOverviewResponse struct {
	Item *PipelineOverviewItem `json:"item"`
}

type BatchStatusItem struct {
	BatchID      string `db:"batch_id" json:"batch_id"`
	UserID       int64  `db:"user_id" json:"user_id"`
	EventsCount  int    `db:"events_count" json:"events_count"`
	Status       string `db:"status" json:"status"`
	Source       string `db:"source" json:"source"`
	AppVersion   string `db:"app_version" json:"app_version"`
	Platform     string `db:"platform" json:"platform"`
	ReceivedAt   string `db:"received_at" json:"received_at"`
}

type BatchStatusResponse struct {
	Item            *BatchStatusItem `json:"item"`
	AcceptedEvents  int              `json:"accepted_events"`
	RejectedEvents  int              `json:"rejected_events"`
	PendingEvents   int              `json:"pending_events"`
	ProcessingEvents int             `json:"processing_events"`
	ProcessedEvents int              `json:"processed_events"`
	FailedEvents    int              `json:"failed_events"`
}

type InvalidEventItem struct {
	ID         int64  `db:"id" json:"id"`
	BatchID    string `db:"batch_id" json:"batch_id"`
	UserID     int64  `db:"user_id" json:"user_id"`
	RequestID  string `db:"request_id" json:"request_id"`
	EventIndex int    `db:"event_index" json:"event_index"`
	EventName  string `db:"event_name" json:"event_name"`
	Reason     string `db:"reason" json:"reason"`
	ReceivedAt string `db:"received_at" json:"received_at"`
}

type InvalidEventsResponse struct {
	Items []InvalidEventItem `json:"items"`
}