package models

import "time"

type SessionSummary struct {
	UserID               int64
	SessionID            string
	StartedAt            time.Time
	EndedAt              time.Time
	DurationSeconds      int64
	EventsCount          int
	UniqueScreensCount   int
	HasError             bool
	HasNavigationActivity bool
	HasWorkoutActivity   bool
	HasSocialActivity    bool
	HasChatActivity      bool
	HasCalendarActivity  bool
	HasProfileActivity   bool
	HasSettingsActivity  bool
	HasSharingActivity   bool
	ActivityType         string
	Platform             string
	AppVersion           string
}