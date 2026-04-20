package types

type ShareWorkoutRequest struct {
	SessionID       string   `json:"session_id"`
	PublishToFeed   bool     `json:"publish_to_feed"`
	ExistingChatIDs []string `json:"existing_chat_ids"`
	DirectUserIDs   []string `json:"direct_user_ids"`
	Description     string   `json:"description"`
	Location        *string  `json:"location,omitempty"`
}

type ShareWorkoutResponse struct {
	CreatedPostID    *string  `json:"created_post_id,omitempty"`
	DeliveredChatIDs []string `json:"delivered_chat_ids"`
	CreatedChatIDs   []string `json:"created_chat_ids"`
}