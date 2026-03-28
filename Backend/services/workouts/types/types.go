package types

type WorkoutType string

const (
	WorkoutTypeStrength WorkoutType = "strength"
	WorkoutTypeCardio   WorkoutType = "cardio"
	WorkoutTypeYoga     WorkoutType = "yoga"
)

type ExerciseType string

const (
	ExerciseTypeStrength ExerciseType = "strength"
	ExerciseTypeCardio   ExerciseType = "cardio"
	ExerciseTypeYoga     ExerciseType = "yoga"
)

// Exercise is a discriminated union stored as JSONB.
// The Type field determines which additional fields are populated.
type Exercise struct {
	Type        ExerciseType `json:"type"`
	ID          string       `json:"id"`
	Name        string       `json:"name"`
	MuscleGroup string       `json:"muscleGroup"`

	// StrengthExercise fields
	Sets     *int     `json:"sets,omitempty"`
	Reps     *int     `json:"reps,omitempty"`
	WeightKg *float64 `json:"weightKg,omitempty"`

	// CardioExercise fields
	DurationMinutes *int    `json:"durationMinutes,omitempty"`
	Pace            *string `json:"pace,omitempty"`

	// YogaExercise fields
	HoldSeconds *int `json:"holdSeconds,omitempty"`
	BreathCount *int `json:"breathCount,omitempty"`
}

type Workout struct {
	ID        string      `json:"id"`
	UserID    string      `json:"userId"`
	Name      string      `json:"name"`
	Type      WorkoutType `json:"type"`
	Exercises []Exercise  `json:"exercises"`
}
