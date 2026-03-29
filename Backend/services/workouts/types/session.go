package types

import "time"

type SessionExercise struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Type        string  `json:"type"`
	MuscleGroup string  `json:"muscleGroup"`
	Sets            *int     `json:"sets,omitempty"`
	Reps            *int     `json:"reps,omitempty"`
	WeightKg        *float64 `json:"weightKg,omitempty"`
	DurationMinutes *int     `json:"durationMinutes,omitempty"`
	Pace            *string  `json:"pace,omitempty"`
	HoldSeconds     *int     `json:"holdSeconds,omitempty"`
	BreathCount     *int     `json:"breathCount,omitempty"`
}

type WorkoutSession struct {
	ID          string            `json:"id"`
	UserID      string            `json:"userId"`
	WorkoutID   *string           `json:"workoutId"`
	WorkoutName string            `json:"workoutName"`
	WorkoutType string            `json:"workoutType"`
	CompletedAt time.Time         `json:"completedAt"`
	Exercises   []SessionExercise `json:"exercises"`
}

type SessionExerciseInput struct {
	ExerciseID      string   `json:"exerciseId"`
	Sets            *int     `json:"sets,omitempty"`
	Reps            *int     `json:"reps,omitempty"`
	WeightKg        *float64 `json:"weightKg,omitempty"`
	DurationMinutes *int     `json:"durationMinutes,omitempty"`
	Pace            *string  `json:"pace,omitempty"`
	HoldSeconds     *int     `json:"holdSeconds,omitempty"`
	BreathCount     *int     `json:"breathCount,omitempty"`
}

type SessionInput struct {
	ID          string                 `json:"id"`
	UserID      string                 `json:"userId"`
	WorkoutID   string                 `json:"workoutId"`
	CompletedAt *time.Time             `json:"completedAt"`
	Exercises   []SessionExerciseInput `json:"exercises"`
}
