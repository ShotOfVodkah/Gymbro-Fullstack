package chats

import (
	"fmt"
	"net/http"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

func (h *ChatHandler) StartTyping(w http.ResponseWriter, r *http.Request) {
	h.publishTyping(w, r, true)
}

func (h *ChatHandler) StopTyping(w http.ResponseWriter, r *http.Request) {
	h.publishTyping(w, r, false)
}

func (h *ChatHandler) publishTyping(w http.ResponseWriter, r *http.Request, isTyping bool) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsResourceSuffix(r.URL.Path, "/typing")
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
		return
	}

	eventType := "typing_stopped"
	if isTyping {
		eventType = "typing_started"
	}

	h.eventHub.Publish(chatID, types.ChatRealtimeEvent{
		Type:    eventType,
		ChatID:  chatID,
		ActorID: fmt.Sprintf("%d", claims.UserID),
		Payload: map[string]any{
			"user_id":   fmt.Sprintf("%d", claims.UserID),
			"is_typing": isTyping,
		},
		CreatedAt: time.Now().UTC(),
	})

	w.WriteHeader(http.StatusNoContent)
}