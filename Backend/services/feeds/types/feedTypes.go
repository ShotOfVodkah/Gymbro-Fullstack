package types

import "time"

type FeedPostRow struct {
	ID                    string    `db:"id"`
	AuthorID              string    `db:"author_id"`
	CommunityID           *string   `db:"community_id"`
	CommunityTitle        *string   `db:"community_title"`
	WorkoutID             *string   `db:"workout_id"`
	Kind                  string    `db:"kind"`
	Description           string    `db:"description"`
	Location              *string   `db:"location"`
	CreatedAt             time.Time `db:"created_at"`
	LikesCount            int       `db:"likes_count"`
	CommentsCount         int       `db:"comments_count"`
	IsLiked               bool      `db:"is_liked"`
	IsFromJoinedCommunity bool      `db:"is_from_joined_community"`
}

type FeedAuthorPreview struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	AvatarURL string `json:"avatar_url"`
}

type FeedCommunityPreview struct {
	ID    string `json:"id"`
	Title string `json:"title"`
}

type FeedWorkoutExercisePreview struct {
	ID              string   `json:"id"`
	Name            string   `json:"name"`
	Type            string   `json:"type"`
	MuscleGroup     string   `json:"muscleGroup"`
	Sets            *int     `json:"sets,omitempty"`
	Reps            *int     `json:"reps,omitempty"`
	WeightKg        *float64 `json:"weightKg,omitempty"`
	DurationMinutes *int     `json:"durationMinutes,omitempty"`
	Pace            *string  `json:"pace,omitempty"`
	HoldSeconds     *int     `json:"holdSeconds,omitempty"`
	BreathCount     *int     `json:"breathCount,omitempty"`
}

type FeedWorkoutPreview struct {
	ID               string                       `json:"id"`
	Title            string                       `json:"title"`
	Category         string                       `json:"category"`
	DurationMinutes  int                          `json:"duration_minutes"`
	ExerciseCount    int                          `json:"exercise_count"`
	ExercisesPreview []FeedWorkoutExercisePreview `json:"exercises_preview"`
}

type FeedPostItemResponse struct {
	ID                    string                `json:"id"`
	Author                FeedAuthorPreview     `json:"author"`
	Community             *FeedCommunityPreview `json:"community,omitempty"`
	Workout               *FeedWorkoutPreview   `json:"workout,omitempty"`
	Description           string                `json:"description"`
	Location              *string               `json:"location,omitempty"`
	CreatedAt             time.Time             `json:"created_at"`
	LikesCount            int                   `json:"likes_count"`
	CommentsCount         int                   `json:"comments_count"`
	IsLiked               bool                  `json:"is_liked"`
	Kind                  string                `json:"kind"`
	IsFromJoinedCommunity bool                  `json:"is_from_joined_community"`
}

type WorkoutPreviewBatchRequest struct {
	IDs []string `json:"ids"`
}

type WorkoutPreviewExercise struct {
	ID              string   `json:"id"`
	Name            string   `json:"name"`
	Type            string   `json:"type"`
	MuscleGroup     string   `json:"muscleGroup"`
	Sets            *int     `json:"sets,omitempty"`
	Reps            *int     `json:"reps,omitempty"`
	WeightKg        *float64 `json:"weightKg,omitempty"`
	DurationMinutes *int     `json:"durationMinutes,omitempty"`
	Pace            *string  `json:"pace,omitempty"`
	HoldSeconds     *int     `json:"holdSeconds,omitempty"`
	BreathCount     *int     `json:"breathCount,omitempty"`
}

type WorkoutPreviewItem struct {
	ID               string                   `json:"id"`
	Title            string                   `json:"title"`
	Category         string                   `json:"category"`
	DurationMinutes  int                      `json:"duration_minutes"`
	ExerciseCount    int                      `json:"exercise_count"`
	ExercisesPreview []WorkoutPreviewExercise `json:"exercises_preview"`
}

type WorkoutPreviewBatchResponse struct {
	Items []WorkoutPreviewItem `json:"items"`
}