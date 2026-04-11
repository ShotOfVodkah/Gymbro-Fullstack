package types

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

type WorkoutPreviewBatchRequest struct {
	IDs []string `json:"ids"`
}

type WorkoutPreviewBatchResponse struct {
	Items []WorkoutPreviewItem `json:"items"`
}