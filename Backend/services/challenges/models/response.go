package models

import "time"

type ChallengesListResponse struct {
	Challenges []ChallengeResponse `json:"challenges"`
}

type ChallengeResponse struct {
	ID                  string                        `json:"id"`
	Title               string                        `json:"title"`
	Description         string                        `json:"description"`
	Type                string                        `json:"type"`
	Status              string                        `json:"status"`
	ParticipationStatus string                        `json:"participation_status"`
	Difficulty          string                        `json:"difficulty"`
	CoverIcon           string                        `json:"cover_icon"`
	AccentColor         *string                       `json:"accent_color"`
	TargetFilter 		*string 					  `json:"target_filter"`
	StartDate           time.Time                     `json:"start_date"`
	EndDate             time.Time                     `json:"end_date"`
	TargetValue         int                           `json:"target_value"`
	CurrentValue        int                           `json:"current_value"`
	ProgressPercent     float64                       `json:"progress_percent"`
	Unit                string                        `json:"unit"`
	Team                *ChallengeTeamPreviewResponse `json:"team"`
}

type ChallengeDetailsResponse struct {
	ID                  string                         `json:"id"`
	Title               string                         `json:"title"`
	Description         string                         `json:"description"`
	Rules               []string                       `json:"rules"`
	Type                string                         `json:"type"`
	Status              string                         `json:"status"`
	ParticipationStatus string                         `json:"participation_status"`
	Difficulty          string                         `json:"difficulty"`
	CoverIcon           string                         `json:"cover_icon"`
	AccentColor         *string                        `json:"accent_color"`
	TargetFilter 		*string 					  `json:"target_filter"`
	StartDate           time.Time                      `json:"start_date"`
	EndDate             time.Time                      `json:"end_date"`
	TargetValue         int                            `json:"target_value"`
	CurrentValue        int                            `json:"current_value"`
	ProgressPercent     float64                        `json:"progress_percent"`
	Unit                string                         `json:"unit"`
	Team                *ChallengeTeamResponse         `json:"team"`
	Participants        []ChallengeParticipantResponse `json:"participants"`
	Rewards             []ChallengeRewardResponse      `json:"rewards"`
}

type ChallengeTeamPreviewResponse struct {
	TeamID   string `json:"team_id"`
	ChatID   string `json:"chat_id"`
	TeamName string `json:"team_name"`
}

type ChallengeTeamResponse struct {
	TeamID          string    `json:"team_id"`
	ChallengeID     string    `json:"challenge_id"`
	ChatID          string    `json:"chat_id"`
	TeamName        string    `json:"team_name"`
	TeamAvatar      string    `json:"team_avatar"`
	MembersCount    int       `json:"members_count"`
	CurrentValue    int       `json:"current_value"`
	TargetValue     int       `json:"target_value"`
	ProgressPercent float64   `json:"progress_percent"`
	Status          string    `json:"status"`
	JoinedAt        time.Time `json:"joined_at"`
}

type ChallengeParticipantResponse struct {
	UserID            int64      `json:"user_id"`
	Name              string     `json:"name"`
	AvatarSystemName  string     `json:"avatar_system_name"`
	ContributionValue int        `json:"contribution_value"`
	ContributionUnit  string     `json:"contribution_unit"`
	RankInTeam        int        `json:"rank_in_team"`
	LastActivityAt    *time.Time `json:"last_activity_at"`
	IsMVP             bool       `json:"is_mvp"`
}

type ChallengeActivityResponse struct {
	ID               string    `json:"id"`
	UserID           int64     `json:"user_id"`
	UserName         string    `json:"user_name"`
	AvatarSystemName string    `json:"avatar_system_name"`
	Action           string    `json:"action"`
	Value            int       `json:"value"`
	Unit             string    `json:"unit"`
	SourceID         *string   `json:"source_id"`
	CreatedAt        time.Time `json:"created_at"`
}

type ChallengeLeaderboardResponse struct {
	ChallengeID  string                             `json:"challenge_id"`
	Leaderboard []ChallengeLeaderboardTeamResponse `json:"leaderboard"`
}

type ChallengeLeaderboardTeamResponse struct {
	Rank              int     `json:"rank"`
	TeamID            string  `json:"team_id"`
	ChatID            string  `json:"chat_id"`
	TeamName          string  `json:"team_name"`
	TeamAvatar        string  `json:"team_avatar"`
	MembersCount      int     `json:"members_count"`
	CurrentValue      int     `json:"current_value"`
	TargetValue       int     `json:"target_value"`
	ProgressPercent   float64 `json:"progress_percent"`
	Status            string  `json:"status"`
	IsCurrentUserTeam bool    `json:"is_current_user_team"`
}

type AvailableChallengeTeamsResponse struct {
	Teams []AvailableChallengeTeamResponse `json:"teams"`
}

type AvailableChallengeTeamResponse struct {
	ChatID           string  `json:"chat_id"`
	ChatName         string  `json:"chat_name"`
	AvatarSystemName string  `json:"avatar_system_name"`
	MembersCount     int     `json:"members_count"`
	CanJoin          bool    `json:"can_join"`
	Reason           *string `json:"reason"`
}

type JoinChallengeResponse struct {
	TeamID          string  `json:"team_id"`
	ChallengeID     string  `json:"challenge_id"`
	ChatID          string  `json:"chat_id"`
	TeamName        string  `json:"team_name"`
	Status          string  `json:"status"`
	CurrentValue    int     `json:"current_value"`
	TargetValue     int     `json:"target_value"`
	ProgressPercent float64 `json:"progress_percent"`
}

type LeaveChallengeResponse struct {
	Status string `json:"status"`
}

type ChallengeRewardResponse struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	IconName    string `json:"icon_name"`
	IsUnlocked  bool   `json:"is_unlocked"`
}