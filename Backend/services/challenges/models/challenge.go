package models

import "time"

type Challenge struct {
	ID           string    `db:"id"`
	Title        string    `db:"title"`
	Description  string    `db:"description"`
	Type         string    `db:"type"`
	Status       string    `db:"status"`
	Difficulty   string    `db:"difficulty"`
	CoverIcon    string    `db:"cover_icon"`
	AccentColor  *string   `db:"accent_color"`
	TargetFilter *string   `db:"target_filter"`
	StartDate    time.Time `db:"start_date"`
	EndDate      time.Time `db:"end_date"`
	TargetValue  int       `db:"target_value"`
	Unit         string    `db:"unit"`
	CreatedAt    time.Time `db:"created_at"`
	UpdatedAt    time.Time `db:"updated_at"`
}

type ChallengeTeam struct {
	ID              string     `db:"id"`
	ChallengeID     string     `db:"challenge_id"`
	ChatID          string     `db:"chat_id"`
	TeamName        string     `db:"team_name"`
	TeamAvatar      string     `db:"team_avatar"`
	Status          string     `db:"status"`
	CurrentValue    int        `db:"current_value"`
	TargetValue     int        `db:"target_value"`
	JoinedAt        time.Time  `db:"joined_at"`
	CompletedAt     *time.Time `db:"completed_at"`
	FailedAt        *time.Time `db:"failed_at"`
}

type ChallengeParticipantStat struct {
	ID                string     `db:"id"`
	ChallengeID       string     `db:"challenge_id"`
	TeamID            string     `db:"team_id"`
	UserID            int64      `db:"user_id"`
	ContributionValue int        `db:"contribution_value"`
	LastActivityAt    *time.Time `db:"last_activity_at"`
}

type ChallengeProgressEvent struct {
	ID          string    `db:"id"`
	ChallengeID string    `db:"challenge_id"`
	TeamID      string    `db:"team_id"`
	UserID      int64     `db:"user_id"`
	SourceType  string    `db:"source_type"`
	SourceID    string    `db:"source_id"`
	Value       int       `db:"value"`
	CreatedAt   time.Time `db:"created_at"`
}