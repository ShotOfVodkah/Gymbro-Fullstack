package types

import "time"

type FeedPostRow struct {
	ID                    string    `db:"id"`
	AuthorID              string    `db:"author_id"`
	CommunityID        	  *string   `db:"community_id"`
	CommunityTitle     	  *string   `db:"community_title"`
	SessionID          	  *string   `db:"session_id"`
	Kind               	  string    `db:"kind"`
	Description       	  string    `db:"description"`
	Location           	  *string   `db:"location"`
	CreatedAt          	  time.Time `db:"created_at"`
	LikesCount         	  int       `db:"likes_count"`
	CommentsCount      	  int       `db:"comments_count"`
	IsLiked            	  bool      `db:"is_liked"`
	IsFromFollowing    	  bool      `db:"is_from_following"`
	IsFromDirectChat   	  bool      `db:"is_from_direct_chat"`
	IsFromGroupCommunity  bool    `db:"is_from_group_community"`
}

type FeedCommunityRow struct {
	ID           string `db:"id"`
	Title        string `db:"title"`
	Kind         string `db:"kind"`
	MembersCount int    `db:"members_count"`
	OtherUserID  *int   `db:"other_user_id"`
}

type FeedCommentRow struct {
	ID        string    `db:"id"`
	PostID    string    `db:"post_id"`
	AuthorID  int       `db:"author_id"`
	Content   string    `db:"content"`
	CreatedAt time.Time `db:"created_at"`
}

type FeedAuthorPreview struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	AvatarURL string `json:"avatar_url"`
}

type FeedCommunityPreview struct {
	ID    string `json:"id"`
	Title string `json:"title"`
}

type FeedWorkoutExercisePreview struct {
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

type FeedWorkoutPreview struct {
	ID               string                       `json:"id"`
	Title            string                       `json:"title"`
	Category         string                       `json:"category"`
	DurationMinutes  int                          `json:"duration_minutes"`
	ExerciseCount    int                          `json:"exercise_count"`
	ExercisesPreview []FeedWorkoutExercisePreview `json:"exercises_preview"`
}

type SessionPreviewExercise struct {
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

type SessionPreviewItem struct {
	ID               string                   `json:"id"`
	Title            string                   `json:"title"`
	Category         string                   `json:"category"`
	DurationMinutes  int                      `json:"duration_minutes"`
	ExerciseCount    int                      `json:"exercise_count"`
	ExercisesPreview []SessionPreviewExercise `json:"exercises_preview"`
}

type FeedPostItemResponse struct {
	ID                   string                `json:"id"`
	Author               FeedAuthorPreview     `json:"author"`
	Community            *FeedCommunityPreview `json:"community,omitempty"`
	Workout              *FeedWorkoutPreview   `json:"workout,omitempty"`
	Description          string                `json:"description"`
	Location             *string               `json:"location,omitempty"`
	CreatedAt            time.Time             `json:"created_at"`
	LikesCount           int                   `json:"likes_count"`
	CommentsCount        int                   `json:"comments_count"`
	IsLiked              bool                  `json:"is_liked"`
	Kind                 string                `json:"kind"`
	IsFromFollowing      bool                  `json:"is_from_following"`
	IsFromDirectChat     bool                  `json:"is_from_direct_chat"`
	IsFromGroupCommunity bool                  `json:"is_from_group_community"`
}

type SessionPreviewBatchResponse struct {
	Items []SessionPreviewItem `json:"items"`
}

type FeedCommunityItemResponse struct {
	ID            string `json:"id"`
	Title         string `json:"title"`
	DisplayTitle  string `json:"display_title"`
	Kind          string `json:"kind"`
	Icon          string `json:"icon"`
	IsSystemImage bool   `json:"is_system_image"`
	MembersCount  int    `json:"members_count"`
}

type FeedCommentResponse struct {
	ID        string             `json:"id"`
	Author    FeedAuthorPreview  `json:"author"`
	Text      string             `json:"text"`
	CreatedAt time.Time          `json:"created_at"`
}

type FeedLikeResponse struct {
	PostID     string `json:"post_id" db:"post_id"`
	LikesCount int    `json:"likes_count" db:"likes_count"`
	IsLiked    bool   `json:"is_liked" db:"is_liked"`
}

type CreateFeedPostResponse struct {
	ID                   string                `json:"id"`
	Author               FeedAuthorPreview     `json:"author"`
	Community            *FeedCommunityPreview `json:"community,omitempty"`
	Workout              *FeedWorkoutPreview   `json:"workout,omitempty"`
	Description          string                `json:"description"`
	Location             *string               `json:"location,omitempty"`
	CreatedAt            time.Time             `json:"created_at"`
	LikesCount           int                   `json:"likes_count"`
	CommentsCount        int                   `json:"comments_count"`
	IsLiked              bool                  `json:"is_liked"`
	Kind                 string                `json:"kind"`
	IsFromFollowing      bool                  `json:"is_from_following"`
	IsFromDirectChat     bool                  `json:"is_from_direct_chat"`
	IsFromGroupCommunity bool                  `json:"is_from_group_community"`

}

type SessionPreviewBatchRequest struct {
	IDs []string `json:"ids"`
}

type CreateFeedCommentRequest struct {
	Text string `json:"text"`
}

type CreateFeedPostRequest struct {
	SessionID   string  `json:"session_id"`
	Description string  `json:"description"`
	Location    *string `json:"location,omitempty"`
	CommunityID *string `json:"community_id,omitempty"`
}
