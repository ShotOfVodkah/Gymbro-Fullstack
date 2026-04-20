package feeds

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

func (h *FeedHandler) CreatePost(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	var req types.CreateFeedPostRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	if strings.TrimSpace(req.SessionID) == "" {
		http.Error(w, "session_id is required", http.StatusBadRequest)
		return
	}

	row, err := h.store.InsertPost(
		claims.UserID,
		req.SessionID,
		strings.TrimSpace(req.Description),
		req.Location,
		req.CommunityID,
		"personal",
	)
	if err != nil {
		http.Error(w, "failed to create post", http.StatusInternalServerError)
		return
	}

	sessionMap, err := h.workoutsClient.FetchSessionPreviews(r.Context(), []string{req.SessionID})
	if err != nil {
		http.Error(w, "failed to fetch session preview", http.StatusInternalServerError)
		return
	}

	profilesMap, err := h.profileClient.FetchProfilesBatch(r.Context(), []int{claims.UserID})
	if err != nil {
		http.Error(w, "failed to fetch author profile", http.StatusInternalServerError)
		return
	}

	resp := h.buildFeedPostResponse(
		r,
		*row,
		sessionMap,
		profilesMap,
	)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(resp)
}

func (h *FeedHandler) ShareWorkout(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	var req types.ShareWorkoutRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}
	resp, err := h.shareService.ShareWorkout(r.Context(), claims.UserID, req)
	if err != nil {
		switch err {
		case ErrBadRequest:
			http.Error(w, "bad request", http.StatusBadRequest)
		case ErrForbidden:
			http.Error(w, "forbidden", http.StatusForbidden)
		default:
			http.Error(w, "failed to share workout", http.StatusInternalServerError)
		}
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(resp)
}