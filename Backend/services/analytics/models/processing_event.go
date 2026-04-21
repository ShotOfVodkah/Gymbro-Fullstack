package models

import (
	"encoding/json"
	"time"
)

type ProcessableEvent struct {
	ID             int64           `db:"id"`
	BatchID        string          `db:"batch_id"`
	UserID         int64           `db:"user_id"`
	SessionID      string          `db:"session_id"`
	EventName      string          `db:"event_name"`
	EventDate      string          `db:"event_date"`
	EventTime      time.Time       `db:"event_time"`
	Screen         *string         `db:"screen"`
	Platform       string          `db:"platform"`
	AppVersion     string          `db:"app_version"`
	EventCategory  *string         `db:"event_category"`
	IsErrorEvent   bool            `db:"is_error_event"`
	EntityType     *string         `db:"entity_type"`
	EntityID       *string         `db:"entity_id"`
	Properties     json.RawMessage `db:"properties"`
	RequestID      *string         `db:"request_id"`
}