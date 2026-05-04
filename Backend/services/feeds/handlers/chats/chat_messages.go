package chats

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"fmt"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

func (h *ChatHandler) GetChatMessages(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsResourceSuffix(r.URL.Path, "/messages")
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
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
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsResourceSuffix(r.URL.Path, "/messages")
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
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

	h.eventHub.Publish(chatID, types.ChatRealtimeEvent{
		Type:      "new_message",
		ChatID:    chatID,
		ActorID:   fmt.Sprintf("%d", claims.UserID),
		Payload:   resp[0],
		CreatedAt: time.Now().UTC(),
	})

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(resp[0])
}

func (h *ChatHandler) ToggleMessageReaction(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
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

	h.eventHub.Publish(message.CommunityID, types.ChatRealtimeEvent{
		Type:    "reaction_updated",
		ChatID:  message.CommunityID,
		ActorID: fmt.Sprintf("%d", claims.UserID),
		Payload: map[string]any{
			"message_id": messageID,
			"reactions":  reactions,
		},
		CreatedAt: time.Now().UTC(),
	})

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(reactions)
}
