package types

import "time"

type ChatParticipantResponse struct {
	ID               string `json:"id"`
	Name             string `json:"name"`
	AvatarSystemName string `json:"avatar_system_name"`
}

type ChatRoomResponse struct {
	ID           string                    `json:"id"`
	Kind         string                    `json:"kind"`
	Title        *string                   `json:"title,omitempty"`
	Description  *string                   `json:"description,omitempty"`
	Participants []ChatParticipantResponse `json:"participants"`
}

type ChatReactionResponse struct {
	Emoji          string `json:"emoji"`
	Count          int    `json:"count"`
	IsSelectedByMe bool   `json:"is_selected_by_me"`
}

type ChatWorkoutAttachmentResponse struct {
	SessionID string `json:"session_id,omitempty"`
	Title     string  `json:"title"`
	Subtitle  string  `json:"subtitle"`
	Duration  string  `json:"duration"`
	Category  string  `json:"category"`
}

type ChatMessageResponse struct {
	ID                     string                        `json:"id"`
	SenderID               string                        `json:"sender_id"`
	SenderName             string                        `json:"sender_name"`
	SenderAvatarSystemName string                        `json:"sender_avatar_system_name"`
	SentAt                 time.Time                     `json:"sent_at"`
	IsMine                 bool                          `json:"is_mine"`
	Kind                   string                        `json:"kind"`
	Text                   *string                       `json:"text,omitempty"`
	Workout                *ChatWorkoutAttachmentResponse `json:"workout,omitempty"`
	Reactions              []ChatReactionResponse        `json:"reactions"`
}

type CreateDirectChatRequest struct {
	ParticipantID string `json:"participant_id"`
}

type CreateGroupChatRequest struct {
	Title          string   `json:"title"`
	Description    string   `json:"description"`
	ParticipantIDs []string `json:"participant_ids"`
}

type SendChatMessageRequest struct {
	Kind      string  `json:"kind"`
	Text      *string `json:"text,omitempty"`
	SessionID *string `json:"session_id,omitempty"`
}

type ToggleReactionRequest struct {
	Emoji string `json:"emoji"`
}

type UpdateGroupChatRequest struct {
	Title       string `json:"title"`
	Description string `json:"description"`
}

type AddChatMembersRequest struct {
	UserIDs []string `json:"user_ids"`
}

