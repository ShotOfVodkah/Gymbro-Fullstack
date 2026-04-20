package types

type CalendarWorkoutDayResponse struct {
	Date            string `json:"date" db:"date"`
	WorkoutID       string `json:"workout_id" db:"workout_id"`
	Title           string `json:"title" db:"title"`
	Category        string `json:"category" db:"category"`
	DurationMinutes int    `json:"duration_minutes" db:"duration_minutes"`
	CompletedAt     string `json:"completed_at" db:"completed_at"`
}