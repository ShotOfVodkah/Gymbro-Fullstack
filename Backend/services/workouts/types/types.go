package types

type WorkoutType string

const (
	WorkoutTypeStrength WorkoutType = "strength"
	WorkoutTypeCardio   WorkoutType = "cardio"
	WorkoutTypeYoga     WorkoutType = "yoga"
)

// CatalogExercise is an entry in the exercise catalog table.
type CatalogExercise struct {
	ID          string `json:"id"          db:"id"`
	Name        string `json:"name"        db:"name"`
	Type        string `json:"type"        db:"type"`
	MuscleGroup string `json:"muscleGroup" db:"muscle_group"`
}

// WorkoutExerciseInput is what the client sends when creating/updating a workout.
// Only the reference to the catalog + execution params are required.
type WorkoutExerciseInput struct {
	ExerciseID      string   `json:"exerciseId"`
	Sets            *int     `json:"sets,omitempty"`
	Reps            *int     `json:"reps,omitempty"`
	WeightKg        *float64 `json:"weightKg,omitempty"`
	DurationMinutes *int     `json:"durationMinutes,omitempty"`
	Pace            *string  `json:"pace,omitempty"`
	HoldSeconds     *int     `json:"holdSeconds,omitempty"`
	BreathCount     *int     `json:"breathCount,omitempty"`
}

// WorkoutInput is what the client sends when creating/updating a workout.
type WorkoutInput struct {
	ID        string                 `json:"id"`
	UserID    string                 `json:"userId"`
	Name      string                 `json:"name"`
	Type      WorkoutType            `json:"type"`
	Exercises []WorkoutExerciseInput `json:"exercises"`
}

// Exercise is a fully enriched exercise as returned in API responses —
// catalog metadata joined with execution params from workout_exercises.
type Exercise struct {
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

// Workout is the full response object returned by the API.
type Workout struct {
	ID        string      `json:"id"`
	UserID    string      `json:"userId"`
	Name      string      `json:"name"`
	Type      WorkoutType `json:"type"`
	Exercises []Exercise  `json:"exercises"`
}
