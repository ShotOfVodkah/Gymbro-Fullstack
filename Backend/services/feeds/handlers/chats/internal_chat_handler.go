package chats

import (
	"encoding/json"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type InternalChatHandler struct {
	chatStore store.ChatStore
	secret    string
}

func NewInternalChatHandler(chatStore store.ChatStore) *InternalChatHandler {
	return &InternalChatHandler{
		chatStore: chatStore,
		secret:    os.Getenv("INTERNAL_SERVICE_SECRET"),
	}
}

func (h *InternalChatHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Header.Get("X-Internal-Secret") != h.secret {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	switch {
	case r.Method == http.MethodPost && strings.HasPrefix(r.URL.Path, "/internal/chats/") && strings.HasSuffix(r.URL.Path, "/system-message"):
		h.SendSystemMessage(w, r)
		return

	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/internal/chats/users/") && strings.HasSuffix(r.URL.Path, "/groups"):
		h.GetUserGroupChats(w, r)
		return

	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/internal/chats/") && strings.HasSuffix(r.URL.Path, "/members"):
		h.GetChatMembers(w, r)
		return

	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/internal/chats/"):
		h.GetChat(w, r)
		return

	default:
		http.NotFound(w, r)
	}
}

func (h *InternalChatHandler) GetUserGroupChats(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/internal/chats/users/")
	userIDPart := strings.TrimSuffix(path, "/groups")

	userID, err := strconv.Atoi(userIDPart)
	if err != nil {
		http.Error(w, "invalid user id", http.StatusBadRequest)
		return
	}

	chats, err := h.chatStore.ListGroupCommunitiesForUser(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJSON(w, chats)
}

func (h *InternalChatHandler) GetChat(w http.ResponseWriter, r *http.Request) {
	chatID := strings.TrimPrefix(r.URL.Path, "/internal/chats/")
	chatID = strings.TrimSuffix(chatID, "/members")

	chat, err := h.chatStore.GetCommunityByID(chatID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	members, err := h.chatStore.ListCommunityMembers(chatID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJSON(w, map[string]any{
		"id":                 chat.ID,
		"title":              chat.Title,
		"kind":               chat.Kind,
		"avatar_system_name":  "person.3.fill",
		"members_count":      len(members),
		"is_group":           chat.Kind == "joined_group",
	})
}

func (h *InternalChatHandler) GetChatMembers(w http.ResponseWriter, r *http.Request) {
	chatID := strings.TrimPrefix(r.URL.Path, "/internal/chats/")
	chatID = strings.TrimSuffix(chatID, "/members")

	members, err := h.chatStore.ListCommunityMembers(chatID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJSON(w, members)
}

func (h *InternalChatHandler) SendSystemMessage(w http.ResponseWriter, r *http.Request) {
	chatID := strings.TrimPrefix(r.URL.Path, "/internal/chats/")
	chatID = strings.TrimSuffix(chatID, "/system-message")

	var req types.InternalSystemMessageRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	if req.Kind == "" || req.Text == "" {
		http.Error(w, "kind and text are required", http.StatusBadRequest)
		return
	}

	message, err := h.chatStore.InsertSystemMessage(chatID, req.Kind, req.Text)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJSON(w, message)
}

func writeJSON(w http.ResponseWriter, value any) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(value)
}