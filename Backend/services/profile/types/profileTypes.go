package types

type Profile struct {
	UserID            int     `json:"user_id" db:"user_id"`
	Name              string  `json:"name" db:"name"`
	Username          string  `json:"username" db:"username"`
	Status            string  `json:"status" db:"status"`
	Subtitle          string  `json:"subtitle" db:"subtitle"`
	AvatarSystemName  string  `json:"avatar_system_name" db:"avatar_system_name"`
	Badge             *string `json:"badge,omitempty" db:"badge"`
	WorkoutsThisMonth int     `json:"workouts_this_month" db:"workouts_this_month"`
}

type BatchProfilesRequest struct {
	IDs []int `json:"ids"`
}