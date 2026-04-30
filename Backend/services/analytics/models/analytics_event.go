package models

import "time"

type AnalyticsEventDTO struct {
	EventName  string            `json:"eventName"`
	Properties map[string]string `json:"properties"`
	Timestamp  time.Time         `json:"timestamp"`
	SessionID  string            `json:"sessionId"`
	UserID     string            `json:"userId"`
	Platform   string            `json:"platform"`
	AppVersion string            `json:"appVersion"`
}

type IngestBatchResponse struct {
	BatchID      string `json:"batch_id"`
	Accepted     int    `json:"accepted"`
	Rejected     int    `json:"rejected"`
	Deduplicated int    `json:"deduplicated"`
}

type IngestedEvent struct {
	Event              AnalyticsEventDTO
	IsValid            bool
	RejectReason       string
	EventDate          string
	Screen             *string
	EventCategory      string
	IsErrorEvent       bool
	EntityType         *string
	EntityID           *string

	WorkoutID          *string
	PostID             *string
	PersonID           *string
	TargetUserID       *string
	CommunityID        *string

	NormalizedTime     time.Time
	RawPayloadSize     int
	PropertiesSize     int
	NormalizedName     string
	NormalizedPlatform string
	EventFingerprint   string
}

type InternalAnalyticsEventRequest struct {
	EventName  string            `json:"event_name"`
	Properties map[string]string `json:"properties"`
	Timestamp  string            `json:"timestamp"`
	Platform   string            `json:"platform"`
}