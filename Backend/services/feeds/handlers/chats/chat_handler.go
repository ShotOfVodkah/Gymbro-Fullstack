package chats

import (
	"net/http"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
)

type ChatHandler struct {
	chatStore      store.ChatStore
	profileClient  *clients.ProfileClient
	workoutsClient *clients.WorkoutsClient
	eventHub       *ChatEventHub
}

func NewChatHandler(
	chatStore store.ChatStore,
	profileClient *clients.ProfileClient,
	workoutsClient *clients.WorkoutsClient,
	eventHub *ChatEventHub,
) *ChatHandler {
	return &ChatHandler{
		chatStore:      chatStore,
		profileClient:  profileClient,
		workoutsClient: workoutsClient,
		eventHub:       eventHub,
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

	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/chats/") && strings.HasSuffix(r.URL.Path, "/stream"):
		h.StreamChatEvents(w, r)
		return
		
	case r.Method == http.MethodPost && strings.HasPrefix(r.URL.Path, "/chats/") && strings.HasSuffix(r.URL.Path, "/read"):
		h.MarkChatRead(w, r)
		return

	case r.Method == http.MethodPost && strings.HasPrefix(r.URL.Path, "/chats/") && strings.HasSuffix(r.URL.Path, "/typing"):
		h.StartTyping(w, r)
		return

	case r.Method == http.MethodDelete && strings.HasPrefix(r.URL.Path, "/chats/") && strings.HasSuffix(r.URL.Path, "/typing"):
		h.StopTyping(w, r)
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
