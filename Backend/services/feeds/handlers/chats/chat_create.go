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

func (h *ChatHandler) CreateDirectChat(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	var req types.CreateDirectChatRequest
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
	claims, ok := authmw.GetClaims(r.Context())
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
