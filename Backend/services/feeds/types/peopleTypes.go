package types

type PersonItemResponse struct {
	ID                string  `json:"id"`
	Name              string  `json:"name"`
	Username          string  `json:"username"`
	Status            string  `json:"status"`
	Subtitle          string  `json:"subtitle"`
	AvatarSystemName  string  `json:"avatar_system_name"`
	IsFollowing       bool    `json:"is_following"`
	IsCurrentFriend   bool    `json:"is_current_friend"`
	Badge             *string `json:"badge,omitempty"`
	WorkoutsThisMonth int     `json:"workouts_this_month"`
}