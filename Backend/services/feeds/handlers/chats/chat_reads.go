package chats

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

func (h *ChatHandler) MarkChatRead(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsResourceSuffix(r.URL.Path, "/read")
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
		return
	}

	var req types.MarkChatReadRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

	state, err := h.chatStore.MarkCommunityRead(chatID, claims.UserID, req.LastReadMessageID)
	if err != nil {
		http.Error(w, "failed to mark chat read", http.StatusInternalServerError)
		return
	}

	resp := types.ChatReadResponse{
		CommunityID:       state.CommunityID,
		UserID:            fmt.Sprintf("%d", state.UserID),
		LastReadMessageID: state.LastReadMessageID,
		LastReadAt:        state.LastReadAt,
	}

	h.eventHub.Publish(chatID, types.ChatRealtimeEvent{
		Type:      "read_updated",
		ChatID:    chatID,
		ActorID:   fmt.Sprintf("%d", claims.UserID),
		Payload:   resp,
		CreatedAt: time.Now().UTC(),
	})

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}