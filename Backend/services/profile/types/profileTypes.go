package types

import "encoding/json"

type Profile struct {
	UserID            int     `json:"user_id" db:"user_id"`
	Name              string  `json:"name" db:"name"`
	Username          string  `json:"username" db:"username"`
	Status            string  `json:"status" db:"status"`
	Subtitle          string  `json:"subtitle" db:"subtitle"`
	Bio               string  `json:"bio" db:"bio"`
	AvatarSystemName  string  `json:"avatar_system_name" db:"avatar_system_name"`
	Badge             *string `json:"badge,omitempty" db:"badge"`
	WorkoutsThisMonth int     `json:"workouts_this_month" db:"workouts_this_month"`
}

type BatchProfilesRequest struct {
	IDs []int `json:"ids"`
}

type InternalUpsertStatisticsRequest struct {
	UserID  int             `json:"user_id"`
	Payload json.RawMessage `json:"payload"`
}


type MeProfileResponse struct {
	UserID           int    `json:"user_id"`
	Name             string `json:"name"`
	Username         string `json:"username"`
	Status           string `json:"status"`
	Subtitle         string `json:"subtitle"`
	Bio              string `json:"bio"`
	AvatarSystemName string `json:"avatar_system_name"`
}

type PatchMeRequest struct {
	Name             *string `json:"name"`
	Username         *string `json:"username"`
	Status           *string `json:"status"`
	Subtitle         *string `json:"subtitle"`
	Bio              *string `json:"bio"`
	AvatarSystemName *string `json:"avatar_system_name"`
}


type ProfileSettings struct {
	UserID                    int    `json:"user_id" db:"user_id"`
	PushNotificationsEnabled  bool   `json:"push_notifications_enabled" db:"push_notifications_enabled"`
	WorkoutReminders          bool   `json:"workout_reminders" db:"workout_reminders"`
	PrivateAccount            bool   `json:"private_account" db:"private_account"`
	ShowActivity              bool   `json:"show_activity" db:"show_activity"`
	DiscoverVisibility        bool   `json:"discover_visibility" db:"discover_visibility"`
}

type PatchSettingsRequest struct {
	PushNotificationsEnabled *bool `json:"push_notifications_enabled"`
	WorkoutReminders         *bool `json:"workout_reminders"`
	PrivateAccount           *bool `json:"private_account"`
	ShowActivity             *bool `json:"show_activity"`
	DiscoverVisibility       *bool `json:"discover_visibility"`
}


type StatisticsSummary struct {
	TotalWorkouts                 int    `json:"total_workouts"`
	TotalDurationHours            int    `json:"total_duration_hours"`
	Consistency                   int    `json:"consistency"`
	WorkoutsThisWeek              int    `json:"workouts_this_week"`
	WorkoutsThisMonth             int    `json:"workouts_this_month"`
	AverageWorkoutDurationMinutes int    `json:"average_workout_duration_minutes"`
	CompletionRate                int    `json:"completion_rate"`
	FavoriteMuscleGroup           string `json:"favorite_muscle_group"`
	MostActiveDay                 string `json:"most_active_day"`
}

type WeeklyActivityPoint struct {
	ID    string `json:"id"`
	Label string `json:"label"`
	Value int    `json:"value"`
}

type TrendPoint struct {
	ID    string `json:"id"`
	Label string `json:"label"`
	Value int    `json:"value"`
}

type WorkoutByMonthPoint struct {
	ID         string `json:"id"`
	MonthLabel string `json:"month_label"`
	Value      int    `json:"value"`
}

type CategoryPoint struct {
	ID    string `json:"id"`
	Title string `json:"title"`
	Value int    `json:"value"`
}

type StatisticsResponse struct {
	UserID           int                   `json:"user_id"`
	Summary          StatisticsSummary     `json:"summary"`
	WeeklyActivity   []WeeklyActivityPoint `json:"weekly_activity"`
	MonthlyTrend     []TrendPoint          `json:"monthly_trend"`
	WorkoutsByMonth  []WorkoutByMonthPoint `json:"workouts_by_month"`
	Categories       []CategoryPoint       `json:"categories"`
}

type StoredStatisticsPayload struct {
	Summary             StatisticsSummary     `json:"summary"`
	WeeklyActivity      []WeeklyActivityPoint `json:"weekly_activity"`
	MonthlyTrend        []TrendPoint          `json:"monthly_trend"`
	WorkoutsByMonth     []WorkoutByMonthPoint `json:"workouts_by_month"`
	Categories          []CategoryPoint       `json:"categories"`
	FavoriteWorkoutType string                `json:"favorite_workout_type"`
	MostActiveWeekday   string                `json:"most_active_weekday"`
}


type MainWeeklyActivity struct {
	ID       string `json:"id"`
	DayTitle string `json:"day_title"`
	Value    int    `json:"value"`
	MaxValue int    `json:"max_value"`
}

type ProfileMainResponse struct {
	UserID              int                  `json:"user_id"`
	Name                string               `json:"name"`
	Username            string               `json:"username"`
	Status              string               `json:"status"`
	Subtitle            string               `json:"subtitle"`
	Bio                 string               `json:"bio"`
	AvatarSystemName    string               `json:"avatar_system_name"`
	Badge               *string              `json:"badge,omitempty"`
	IsFollowing         *bool                `json:"is_following"`
	WorkoutsThisMonth   int                  `json:"workouts_this_month"`
	TotalWorkouts       int                  `json:"total_workouts"`
	TotalHours          int                  `json:"total_hours"`
	FavoriteWorkoutType string               `json:"favorite_workout_type"`
	MostActiveWeekday   string               `json:"most_active_weekday"`
	ConsistencyPercent  int                  `json:"consistency_percent"`
	WeeklyActivity      []MainWeeklyActivity `json:"weekly_activity"`
}
