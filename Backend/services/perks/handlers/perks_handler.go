package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-perks/service"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
)

type PerksHandler struct {
	service *service.PerksService
}

func NewPerksHandler(service *service.PerksService) *PerksHandler {
	return &PerksHandler{
		service: service,
	}
}

func (h *PerksHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.URL.Path {
	case "/perks/me":
		h.handleDashboard(w, r)

	case "/perks/streak":
		h.handleStreak(w, r)

	case "/perks/streak/goal":
		h.handleUpdateWeeklyGoal(w, r)

	case "/perks/streak/freeze/use":
		h.handleUseStreakFreeze(w, r)

	case "/perks/achievements":
		h.handleAchievements(w, r)

	case "/perks/leaderboard":
		h.handleLeaderboard(w, r)

	case "/perks/events":
		h.handleEvents(w, r)

	default:
		writeError(w, http.StatusNotFound, "not found")
	}
}

func (h *PerksHandler) handleDashboard(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user id")
		return
	}

	response, err := h.service.GetDashboard(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *PerksHandler) handleStreak(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user id")
		return
	}

	response, err := h.service.GetStreak(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *PerksHandler) handleUpdateWeeklyGoal(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPatch {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user id")
		return
	}

	var request types.UpdateWeeklyGoalRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	response, err := h.service.UpdateWeeklyGoal(
		r.Context(),
		userID,
		request.WeeklyGoal,
	)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *PerksHandler) handleUseStreakFreeze(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user id")
		return
	}

	var request types.UseStreakFreezeRequest
	_ = json.NewDecoder(r.Body).Decode(&request)

	response, err := h.service.UseStreakFreeze(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *PerksHandler) handleAchievements(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user id")
		return
	}

	response, err := h.service.GetAchievements(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *PerksHandler) handleLeaderboard(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user id")
		return
	}

	filter := r.URL.Query().Get("filter")
	if filter == "" {
		filter = "all"
	}

	sort := r.URL.Query().Get("sort")
	if sort == "" {
		sort = "streak"
	}

	response, err := h.service.GetLeaderboard(
		r.Context(),
		userID,
		filter,
		sort,
	)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *PerksHandler) handleEvents(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user id")
		return
	}

	var request types.PerksEventRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if request.Type == "" {
		writeError(w, http.StatusBadRequest, "event type is required")
		return
	}

	if err := h.service.SaveEvent(r.Context(), userID, request); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	w.WriteHeader(http.StatusOK)
}

func userIDFromRequest(r *http.Request) (int64, bool) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		return 0, false
	}

	return int64(claims.UserID), true
}

func writeJSON(w http.ResponseWriter, statusCode int, value any) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(value)
}

func writeError(w http.ResponseWriter, statusCode int, message string) {
	writeJSON(w, statusCode, map[string]string{
		"error": message,
	})
}