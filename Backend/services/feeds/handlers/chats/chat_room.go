package chats

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

func (h *ChatHandler) GetChat(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsRootID(r.URL.Path)
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
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
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsRootID(r.URL.Path)
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
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
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsRootID(r.URL.Path)
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
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
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	chatID, pathOK := parseChatsResourceSuffix(r.URL.Path, "/members")
	if !pathOK {
		http.NotFound(w, r)
		return
	}

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
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
	claims, ok := authmw.GetClaims(r.Context())
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

	if !h.requireCommunityMember(w, r, chatID, claims.UserID) {
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
