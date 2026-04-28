package types

import "time"

type PerksDashboardResponse struct {
	Streak             StreakResponse        `json:"streak"`
	RecentUnlocks      []AchievementResponse `json:"recentUnlocks"`
	Achievements        []AchievementResponse `json:"achievements"`
	LeaderboardPreview []LeaderboardResponse `json:"leaderboardPreview"`
	MyRank             *MyRankResponse       `json:"myRank"`
}

type StreakResponse struct {
	CurrentStreakWeeks    int       `json:"currentStreakWeeks"`
	BestStreakWeeks       int       `json:"bestStreakWeeks"`
	WeeklyGoal            int       `json:"weeklyGoal"`
	NextWeeklyGoal        *int      `json:"nextWeeklyGoal"`
	CompletedThisWeek     int       `json:"completedThisWeek"`
	RemainingToGoal       int       `json:"remainingToGoal"`
	WeekStartDate         time.Time `json:"weekStartDate"`
	WeekEndDate           time.Time `json:"weekEndDate"`
	IsGoalCompleted       bool      `json:"isGoalCompleted"`
	StreakFreezeCount     int       `json:"streakFreezeCount"`
	CanUseStreakFreeze    bool      `json:"canUseStreakFreeze"`
	WasFreezeUsedThisWeek bool      `json:"wasFreezeUsedThisWeek"`
}

type AchievementResponse struct {
	ID              string     `json:"id" db:"id"`
	Code            string     `json:"code" db:"code"`
	Name            string     `json:"name" db:"name"`
	Description     string     `json:"description" db:"description"`
	IconName        string     `json:"iconName" db:"icon_name"`
	Category        string     `json:"category" db:"category"`
	Rarity          string     `json:"rarity" db:"rarity"`
	Status          string     `json:"status" db:"status"`
	ProgressCurrent int        `json:"progressCurrent" db:"progress_current"`
	ProgressTarget  int        `json:"progressTarget" db:"progress_target"`
	UnlockedAt      *time.Time `json:"unlockedAt" db:"unlocked_at"`
	IsSecret         bool       `json:"isSecret" db:"is_secret"`
}

type LeaderboardResponse struct {
	ID                 string `json:"id"`
	Rank               int    `json:"rank"`
	UserID             string `json:"userID"`
	Name               string `json:"name"`
	Username           string `json:"username"`
	AvatarSystemName   string `json:"avatarSystemName"`
	CurrentStreakWeeks int    `json:"currentStreakWeeks"`
	CompletedWorkouts  int    `json:"completedWorkouts"`
	IsCurrentUser       bool   `json:"isCurrentUser"`
	IsFollowing         bool   `json:"isFollowing"`
	IsFriend            bool   `json:"isFriend"`
}

type MyRankResponse struct {
	Rank               int `json:"rank"`
	CurrentStreakWeeks int `json:"currentStreakWeeks"`
	CompletedWorkouts  int `json:"completedWorkouts"`
}

type UpdateWeeklyGoalRequest struct {
	WeeklyGoal int `json:"weeklyGoal"`
}

type UseStreakFreezeRequest struct{}

type PerksEventRequest struct {
	Type      string            `json:"type"`
	Metadata  map[string]string `json:"metadata"`
	CreatedAt time.Time         `json:"createdAt"`
}
