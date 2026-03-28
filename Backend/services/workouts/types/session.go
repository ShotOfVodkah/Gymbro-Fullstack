package types

import "time"

// SessionExercise is a fully snapshotted exercise inside a completed session.
// All catalog fields (name, type, muscleGroup) are copied at session creation time
// so the record survives deletion of the original exercise.
type SessionExercise struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Type        string  `json:"type"`
	MuscleGroup string  `json:"muscleGroup"`
	// execution params
	Sets            *int     `json:"sets,omitempty"`
	Reps            *int     `json:"reps,omitempty"`
	WeightKg        *float64 `json:"weightKg,omitempty"`
	DurationMinutes *int     `json:"durationMinutes,omitempty"`
	Pace            *string  `json:"pace,omitempty"`
	HoldSeconds     *int     `json:"holdSeconds,omitempty"`
	BreathCount     *int     `json:"breathCount,omitempty"`
}

// WorkoutSession is a completed workout recorded in history.
// WorkoutID may be empty if the original workout template was deleted.
type WorkoutSession struct {
	ID          string            `json:"id"`
	UserID      string            `json:"userId"`
	WorkoutID   *string           `json:"workoutId"`
	WorkoutName string            `json:"workoutName"`
	WorkoutType string            `json:"workoutType"`
	CompletedAt time.Time         `json:"completedAt"`
	Exercises   []SessionExercise `json:"exercises"`
}

// SessionExerciseInput is what the client sends per exercise when recording a session.
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

// SessionInput is the request body for POST /sessions.
type SessionInput struct {
	ID          string                 `json:"id"`
	UserID      string                 `json:"userId"`
	WorkoutID   string                 `json:"workoutId"`
	CompletedAt *time.Time             `json:"completedAt"`
	Exercises   []SessionExerciseInput `json:"exercises"`
}
