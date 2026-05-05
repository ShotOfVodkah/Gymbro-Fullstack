package chats

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

func (h *ChatHandler) StreamChatEvents(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsResourceSuffix(r.URL.Path, "/stream")
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
		return
	}

	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming unsupported", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("X-Accel-Buffering", "no")

	events := h.eventHub.Subscribe(chatID)
	defer func() {
		h.eventHub.Unsubscribe(chatID, events)

	}()

	connected := types.ChatRealtimeEvent{
		Type:      "connected",
		ChatID:    chatID,
		ActorID:   fmt.Sprintf("%d", claims.UserID),
		CreatedAt: time.Now().UTC(),
	}

	writeSSEEvent(w, flusher, connected)

	heartbeat := time.NewTicker(25 * time.Second)
	defer heartbeat.Stop()

	for {
		select {
		case <-r.Context().Done():
			return

		case event := <-events:
			writeSSEEvent(w, flusher, event)

		case <-heartbeat.C:
			_, _ = fmt.Fprintf(w, ": ping\n\n")
			flusher.Flush()
		}
	}
}

func writeSSEEvent(w http.ResponseWriter, flusher http.Flusher, event types.ChatRealtimeEvent) {
	data, err := json.Marshal(event)
	if err != nil {
		return
	}

	_, _ = fmt.Fprintf(w, "event: %s\n", event.Type)
	_, _ = fmt.Fprintf(w, "data: %s\n\n", string(data))
	flusher.Flush()
}