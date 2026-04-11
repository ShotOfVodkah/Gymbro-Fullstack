package types

type CalendarPersonResponse struct {
	ID               string `json:"id"`
	Name             string `json:"name"`
	AvatarSystemName string `json:"avatar_system_name"`
}

type CalendarWorkoutDayResponse struct {
	Date      string `json:"date"`
	WorkoutID string `json:"workout_id"`
}

type CalendarMonthResponse struct {
	Month           string                       `json:"month"`
	MyWorkouts      []CalendarWorkoutDayResponse `json:"my_workouts"`
	PartnerWorkouts []CalendarWorkoutDayResponse `json:"partner_workouts"`
}