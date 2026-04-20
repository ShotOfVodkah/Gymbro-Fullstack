package chats

import (
	"net/http"
	"strings"
)

func (h *ChatHandler) requireCommunityMember(w http.ResponseWriter, r *http.Request, chatID string, userID int) bool {
	if chatID == "" || strings.Contains(chatID, "/") {
		http.NotFound(w, r)
		return false
	}

	isMember, err := h.chatStore.IsCommunityMember(chatID, userID)
	if err != nil {
		http.Error(w, "failed to check membership", http.StatusInternalServerError)
		return false
	}
	if !isMember {
		http.Error(w, "forbidden", http.StatusForbidden)
		return false
	}
	return true
}
