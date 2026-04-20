package chats

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

func (h *ChatHandler) buildChatParticipants(r *http.Request, members []store.CommunityMember) ([]types.ChatParticipantResponse, error) {
	if len(members) == 0 {
		return []types.ChatParticipantResponse{}, nil
	}

	userIDs := make([]int, 0, len(members))
	for _, member := range members {
		userIDs = append(userIDs, member.UserID)
	}

	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), userIDs)
	if err != nil {
		return nil, err
	}

	result := make([]types.ChatParticipantResponse, 0, len(members))
	for _, member := range members {
		profile, ok := profilesMap[member.UserID]
		if !ok {
			continue
		}

		result = append(result, types.ChatParticipantResponse{
			ID:               strconv.Itoa(profile.UserID),
			Name:             profile.Name,
			AvatarSystemName: profile.AvatarSystemName,
		})
	}

	return result, nil
}

func (h *ChatHandler) buildChatRoomResponse(
	r *http.Request,
	currentUserID int,
	communityID string,
) (*types.ChatRoomResponse, error) {
	community, err := h.chatStore.GetCommunityByID(communityID)
	if err != nil {
		return nil, err
	}

	members, err := h.chatStore.ListCommunityMembers(communityID)
	if err != nil {
		return nil, err
	}

	participants, err := h.buildChatParticipants(r, members)
	if err != nil {
		return nil, err
	}

	title := community.Title
	description := community.Description

	if community.Kind == "direct" {
		for _, participant := range participants {
			if participant.ID != strconv.Itoa(currentUserID) {
				title = stringPtr(participant.Name)
				break
			}
		}
		description = nil
	}

	return &types.ChatRoomResponse{
		ID:           community.ID,
		Kind:         community.Kind,
		Title:        title,
		Description:  description,
		Participants: participants,
	}, nil
}

func (h *ChatHandler) buildChatMessagesResponse(
	r *http.Request,
	currentUserID int,
	messages []store.CommunityMessage,
) ([]types.ChatMessageResponse, error) {
	if len(messages) == 0 {
		return []types.ChatMessageResponse{}, nil
	}

	senderIDsSet := make(map[int]struct{})
	messageIDs := make([]string, 0, len(messages))
	sessionIDsSet := make(map[string]struct{})

	for _, message := range messages {
		senderIDsSet[message.SenderID] = struct{}{}
		messageIDs = append(messageIDs, message.ID)

		if message.SessionID != nil && *message.SessionID != "" {
			sessionIDsSet[*message.SessionID] = struct{}{}
		}
	}

	senderIDs := make([]int, 0, len(senderIDsSet))
	for id := range senderIDsSet {
		senderIDs = append(senderIDs, id)
	}

	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), senderIDs)
	if err != nil {
		return nil, fmt.Errorf("fetch sender profiles: %w", err)
	}

	reactionsMap, err := h.chatStore.ListReactionsByMessageIDs(messageIDs, currentUserID)
	if err != nil {
		return nil, fmt.Errorf("fetch message reactions: %w", err)
	}

	sessionIDs := make([]string, 0, len(sessionIDsSet))
	for id := range sessionIDsSet {
		sessionIDs = append(sessionIDs, id)
	}

	sessionPreviewMap := map[string]types.SessionPreviewItem{}
	if len(sessionIDs) > 0 && h.workoutsClient != nil {
		sessionPreviewMap, err = h.workoutsClient.FetchSessionPreviews(r.Context(), sessionIDs)
		if err != nil {
			return nil, fmt.Errorf("fetch session previews: %w", err)
		}
	}

	result := make([]types.ChatMessageResponse, 0, len(messages))
	for _, message := range messages {
		profile, ok := profilesMap[message.SenderID]
		if !ok {
			continue
		}

		resp := types.ChatMessageResponse{
			ID:                     message.ID,
			SenderID:               strconv.Itoa(message.SenderID),
			SenderName:             profile.Name,
			SenderAvatarSystemName: profile.AvatarSystemName,
			SentAt:                 message.CreatedAt,
			IsMine:                 message.SenderID == currentUserID,
			Kind:                   message.Kind,
			Text:                   message.Text,
			Reactions:              reactionsMap[message.ID],
		}

		if resp.Reactions == nil {
			resp.Reactions = []types.ChatReactionResponse{}
		}

		if message.Kind == "workout" {
			resp.Workout = buildWorkoutAttachment(message, sessionPreviewMap)
		}

		result = append(result, resp)
	}

	return result, nil
}

func buildWorkoutAttachment(
	message store.CommunityMessage,
	sessionPreviewMap map[string]types.SessionPreviewItem,
) *types.ChatWorkoutAttachmentResponse {
	if message.SessionID != nil {
		if preview, ok := sessionPreviewMap[*message.SessionID]; ok {
			return &types.ChatWorkoutAttachmentResponse{
				SessionID: *message.SessionID,
				Title:     preview.Title,
				Subtitle:  "Completed session",
				Duration:  formatDurationMinutes(preview.DurationMinutes),
				Category:  preview.Category,
			}
		}

		return &types.ChatWorkoutAttachmentResponse{
			SessionID: *message.SessionID,
			Title:     "Completed workout",
			Subtitle:  "Completed session",
			Duration:  "",
			Category:  "",
		}
	}

	return nil
}

func formatDurationMinutes(minutes int) string {
	if minutes <= 0 {
		return "0 min"
	}
	return fmt.Sprintf("%d min", minutes)
}
