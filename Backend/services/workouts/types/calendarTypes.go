package types

type CalendarWorkoutDayResponse struct {
	Date      string `json:"date" db:"date"`
	WorkoutID string `json:"workout_id" db:"workout_id"`
}