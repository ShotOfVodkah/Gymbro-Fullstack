package models

type JoinChallengeRequest struct {
	ChatID string `json:"chat_id"`
}

type LeaveChallengeRequest struct {
	TeamID string `json:"team_id"`
}

type WorkoutCompletedEventRequest struct {
	UserID          int64    `json:"user_id"`
	SessionID       string   `json:"session_id"`
	WorkoutID       string   `json:"workout_id"`
	WorkoutType     string   `json:"workout_type"`
	DurationMinutes int      `json:"duration_minutes"`
	Calories        int      `json:"calories"`
	ExerciseIDs     []string `json:"exercise_ids"`
	ExerciseTypes   []string `json:"exercise_types"`
	MuscleGroups     []string `json:"muscle_groups"`
	CompletedAt     string   `json:"completed_at"`
}
