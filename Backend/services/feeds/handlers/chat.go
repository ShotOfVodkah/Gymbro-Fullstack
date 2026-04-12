package handlers

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type ChatHandler struct {
	chatStore      store.ChatStore
	profileClient  *clients.ProfileClient
	workoutsClient *clients.WorkoutsClient
}

func NewChatHandler(
	chatStore store.ChatStore,
	profileClient *clients.ProfileClient,
	workoutsClient *clients.WorkoutsClient,
) *ChatHandler {
	return &ChatHandler{
		chatStore:      chatStore,
		profileClient:  profileClient,
		workoutsClient: workoutsClient,
	}
}

func (h *ChatHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodPost && r.URL.Path == "/chats/direct":
		h.CreateDirectChat(w, r)
		return

	case r.Method == http.MethodPost && r.URL.Path == "/chats/group":
		h.CreateGroupChat(w, r)
		return

	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/chats/") && strings.HasSuffix(r.URL.Path, "/messages"):
		h.GetChatMessages(w, r)
		return

	case r.Method == http.MethodPost && strings.HasPrefix(r.URL.Path, "/chats/") && strings.HasSuffix(r.URL.Path, "/messages"):
		h.SendChatMessage(w, r)
		return

	case r.Method == http.MethodPost && strings.HasPrefix(r.URL.Path, "/chats/") && strings.HasSuffix(r.URL.Path, "/members"):
		h.AddChatMembers(w, r)
		return

	case r.Method == http.MethodDelete && strings.HasPrefix(r.URL.Path, "/chats/") && strings.Contains(r.URL.Path, "/members/"):
		h.RemoveChatMember(w, r)
		return

	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/chats/"):
		h.GetChat(w, r)
		return

	case r.Method == http.MethodPatch && strings.HasPrefix(r.URL.Path, "/chats/"):
		h.UpdateChat(w, r)
		return

	case r.Method == http.MethodDelete && strings.HasPrefix(r.URL.Path, "/chats/"):
		h.DeleteChat(w, r)
		return

	case r.Method == http.MethodPost && strings.HasPrefix(r.URL.Path, "/messages/") && strings.HasSuffix(r.URL.Path, "/reactions"):
		h.ToggleMessageReaction(w, r)
		return

	default:
		http.NotFound(w, r)
	}
}

func (h *ChatHandler) CreateDirectChat(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	var req types.CreateDirectChatRequest
	log.Printf("CreateDirectChat called: userID=%d participantID_raw=%s", claims.UserID, req.ParticipantID)
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	participantID, err := strconv.Atoi(req.ParticipantID)
	if err != nil {
		http.Error(w, "invalid participant_id", http.StatusBadRequest)
		return
	}

	if participantID == claims.UserID {
		http.Error(w, "cannot create direct chat with yourself", http.StatusBadRequest)
		return
	}

	community, err := h.chatStore.FindDirectCommunityBetweenUsers(claims.UserID, participantID)
	if err != nil && !errors.Is(err, store.ErrNotFound) {
		http.Error(w, "failed to find direct chat", http.StatusInternalServerError)
		log.Printf("CreateDirectChat find result: community=%v err=%v isNotFound=%v", community, err, errors.Is(err, store.ErrNotFound))
		return
	}

	if errors.Is(err, store.ErrNotFound) {
		directTitle := "Direct chat"

		community, err = h.chatStore.CreateCommunity("direct", stringPtr(directTitle), nil, claims.UserID)
		if err != nil {
			http.Error(w, "failed to create direct chat", http.StatusInternalServerError)
			return
		}

		if err := h.chatStore.AddCommunityMembers(community.ID, []int{claims.UserID, participantID}); err != nil {
			http.Error(w, "failed to add direct chat members", http.StatusInternalServerError)
			return
		}
	}

	resp, err := h.buildChatRoomResponse(r, claims.UserID, community.ID)
	if err != nil {
		http.Error(w, "failed to build direct chat response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *ChatHandler) CreateGroupChat(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	var req types.CreateGroupChatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	title := strings.TrimSpace(req.Title)
	description := strings.TrimSpace(req.Description)

	if title == "" {
		http.Error(w, "title is required", http.StatusBadRequest)
		return
	}

	participantIDs, err := parseUserIDs(req.ParticipantIDs)
	if err != nil {
		http.Error(w, "invalid participant_ids", http.StatusBadRequest)
		return
	}

	community, err := h.chatStore.CreateCommunity(
		"joined_group",
		stringPtr(title),
		stringPtr(description),
		claims.UserID,
	)
	if err != nil {
		http.Error(w, "failed to create group chat", http.StatusInternalServerError)
		return
	}

	allMembers := append([]int{claims.UserID}, participantIDs...)
	allMembers = uniqueInts(allMembers)

	if err := h.chatStore.AddCommunityMembers(community.ID, allMembers); err != nil {
		http.Error(w, "failed to add group chat members", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildChatRoomResponse(r, claims.UserID, community.ID)
	if err != nil {
		http.Error(w, "failed to build group chat response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *ChatHandler) GetChat(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID := strings.TrimPrefix(r.URL.Path, "/chats/")
	if chatID == "" || strings.Contains(chatID, "/") {
		http.NotFound(w, r)
		return
	}

	isMember, err := h.chatStore.IsCommunityMember(chatID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	resp, err := h.buildChatRoomResponse(r, claims.UserID, chatID)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.NotFound(w, r)
			return
		}
		http.Error(w, "failed to load chat", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *ChatHandler) UpdateChat(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID := strings.TrimPrefix(r.URL.Path, "/chats/")
	if chatID == "" || strings.Contains(chatID, "/") {
		http.NotFound(w, r)
		return
	}

	isMember, err := h.chatStore.IsCommunityMember(chatID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	community, err := h.chatStore.GetCommunityByID(chatID)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.NotFound(w, r)
			return
		}
		http.Error(w, "failed to load chat", http.StatusInternalServerError)
		return
	}

	if community.Kind != "joined_group" {
		http.Error(w, "only group chats can be updated", http.StatusBadRequest)
		return
	}

	var req types.UpdateGroupChatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	_, err = h.chatStore.UpdateCommunity(chatID, strings.TrimSpace(req.Title), strings.TrimSpace(req.Description))
	if err != nil {
		http.Error(w, "failed to update chat", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildChatRoomResponse(r, claims.UserID, chatID)
	if err != nil {
		http.Error(w, "failed to build updated chat response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *ChatHandler) DeleteChat(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID := strings.TrimPrefix(r.URL.Path, "/chats/")
	if chatID == "" || strings.Contains(chatID, "/") {
		http.NotFound(w, r)
		return
	}

	isMember, err := h.chatStore.IsCommunityMember(chatID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	community, err := h.chatStore.GetCommunityByID(chatID)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.NotFound(w, r)
			return
		}
		http.Error(w, "failed to load chat", http.StatusInternalServerError)
		return
	}

	if community.Kind != "joined_group" {
		http.Error(w, "only group chats can be deleted", http.StatusBadRequest)
		return
	}

	if err := h.chatStore.DeleteCommunity(chatID); err != nil {
		http.Error(w, "failed to delete chat", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *ChatHandler) AddChatMembers(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID := strings.TrimSuffix(strings.TrimPrefix(r.URL.Path, "/chats/"), "/members")
	if chatID == "" || strings.Contains(chatID, "/") {
		http.NotFound(w, r)
		return
	}

	isMember, err := h.chatStore.IsCommunityMember(chatID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	community, err := h.chatStore.GetCommunityByID(chatID)
	if err != nil {
		http.Error(w, "failed to load chat", http.StatusInternalServerError)
		return
	}
	if community.Kind != "joined_group" {
		http.Error(w, "only group chats can add members", http.StatusBadRequest)
		return
	}

	var req types.AddChatMembersRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	userIDs, err := parseUserIDs(req.UserIDs)
	if err != nil {
		http.Error(w, "invalid user_ids", http.StatusBadRequest)
		return
	}

	if err := h.chatStore.AddCommunityMembers(chatID, uniqueInts(userIDs)); err != nil {
		http.Error(w, "failed to add members", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildChatRoomResponse(r, claims.UserID, chatID)
	if err != nil {
		http.Error(w, "failed to build updated chat response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *ChatHandler) RemoveChatMember(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	rest := strings.TrimPrefix(r.URL.Path, "/chats/")
	parts := strings.Split(rest, "/")
	if len(parts) != 3 || parts[1] != "members" {
		http.NotFound(w, r)
		return
	}

	chatID := parts[0]
	userID, err := strconv.Atoi(parts[2])
	if err != nil {
		http.Error(w, "invalid user id", http.StatusBadRequest)
		return
	}

	isMember, err := h.chatStore.IsCommunityMember(chatID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	community, err := h.chatStore.GetCommunityByID(chatID)
	if err != nil {
		http.Error(w, "failed to load chat", http.StatusInternalServerError)
		return
	}
	if community.Kind != "joined_group" {
		http.Error(w, "only group chats can remove members", http.StatusBadRequest)
		return
	}

	if err := h.chatStore.RemoveCommunityMember(chatID, userID); err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.NotFound(w, r)
			return
		}
		http.Error(w, "failed to remove member", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildChatRoomResponse(r, claims.UserID, chatID)
	if err != nil {
		http.Error(w, "failed to build updated chat response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *ChatHandler) GetChatMessages(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID := strings.TrimSuffix(strings.TrimPrefix(r.URL.Path, "/chats/"), "/messages")
	if chatID == "" || strings.Contains(chatID, "/") {
		http.NotFound(w, r)
		return
	}

	isMember, err := h.chatStore.IsCommunityMember(chatID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	messages, err := h.chatStore.ListMessagesByCommunityID(chatID)
	if err != nil {
		http.Error(w, "failed to load messages", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildChatMessagesResponse(r, claims.UserID, messages)
	if err != nil {
		http.Error(w, "failed to build messages response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *ChatHandler) SendChatMessage(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID := strings.TrimSuffix(strings.TrimPrefix(r.URL.Path, "/chats/"), "/messages")
	if chatID == "" || strings.Contains(chatID, "/") {
		http.NotFound(w, r)
		return
	}

	isMember, err := h.chatStore.IsCommunityMember(chatID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	var req types.SendChatMessageRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	switch req.Kind {
	case "text":
		if req.Text == nil || strings.TrimSpace(*req.Text) == "" {
			http.Error(w, "text is required for text message", http.StatusBadRequest)
			return
		}
	case "workout":
		if req.SessionID == nil || strings.TrimSpace(*req.SessionID) == "" {
			http.Error(w, "session_id is required for workout message", http.StatusBadRequest)
			return
		}
	default:
		http.Error(w, "invalid message kind", http.StatusBadRequest)
		return
	}

	message, err := h.chatStore.InsertMessage(
		chatID,
		claims.UserID,
		req.Kind,
		req.Text,
		req.SessionID,
	)
	if err != nil {
		http.Error(w, "failed to send message", http.StatusInternalServerError)
		return
	}

	resp, err := h.buildChatMessagesResponse(r, claims.UserID, []store.CommunityMessage{*message})
	if err != nil {
		http.Error(w, "failed to build sent message response", http.StatusInternalServerError)
		return
	}
	if len(resp) == 0 {
		http.Error(w, "failed to build sent message response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(resp[0])
}

func (h *ChatHandler) ToggleMessageReaction(w http.ResponseWriter, r *http.Request) {
	claims, ok := GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	messageID := strings.TrimSuffix(strings.TrimPrefix(r.URL.Path, "/messages/"), "/reactions")
	if messageID == "" || strings.Contains(messageID, "/") {
		http.NotFound(w, r)
		return
	}

	message, err := h.chatStore.GetMessageByID(messageID)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			http.NotFound(w, r)
			return
		}
		http.Error(w, "failed to load message", http.StatusInternalServerError)
		return
	}

	isMember, err := h.chatStore.IsCommunityMember(message.CommunityID, claims.UserID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	var req types.ToggleReactionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(req.Emoji) == "" {
		http.Error(w, "emoji is required", http.StatusBadRequest)
		return
	}

	if err := h.chatStore.ToggleReaction(messageID, claims.UserID, req.Emoji); err != nil {
		http.Error(w, "failed to toggle reaction", http.StatusInternalServerError)
		return
	}

	reactionsMap, err := h.chatStore.ListReactionsByMessageIDs([]string{messageID}, claims.UserID)
	if err != nil {
		http.Error(w, "failed to load reactions", http.StatusInternalServerError)
		return
	}

	reactions := reactionsMap[messageID]
	if reactions == nil {
		reactions = []types.ChatReactionResponse{}
	}

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(reactions)
}

func parseUserIDs(values []string) ([]int, error) {
	result := make([]int, 0, len(values))
	for _, value := range values {
		id, err := strconv.Atoi(value)
		if err != nil {
			return nil, err
		}
		result = append(result, id)
	}
	return result, nil
}

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

func uniqueInts(values []int) []int {
	seen := make(map[int]struct{}, len(values))
	result := make([]int, 0, len(values))
	for _, value := range values {
		if _, ok := seen[value]; ok {
			continue
		}
		seen[value] = struct{}{}
		result = append(result, value)
	}
	return result
}

func stringPtr(v string) *string {
	if strings.TrimSpace(v) == "" {
		return nil
	}
	s := v
	return &s
}