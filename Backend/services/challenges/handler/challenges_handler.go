package handler

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-challenges/models"
	"github.com/alexandra-gritsaenko/gymbro-challenges/service"
	"github.com/alexandra-gritsaenko/gymbro-authmw"
)

type ChallengesHandler struct {
	service service.ChallengesService
}

func NewChallengesHandler(service service.ChallengesService) *ChallengesHandler {
	return &ChallengesHandler{service: service}
}

func (h *ChallengesHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	path := strings.Trim(r.URL.Path, "/")
	parts := strings.Split(path, "/")

	if r.Method == http.MethodPost && r.URL.Path == "/internal/challenges/events/workout-completed" {
		h.handleWorkoutCompletedEvent(w, r)
		return
	}

	if len(parts) == 1 && parts[0] == "challenges" {
		if r.Method == http.MethodGet {
			h.listChallenges(w, r)
			return
		}
	}

	if len(parts) >= 2 && parts[0] == "challenges" {
		challengeID := parts[1]

		if len(parts) == 2 && r.Method == http.MethodGet {
			h.getChallengeDetails(w, r, challengeID)
			return
		}

		if len(parts) == 3 {
			switch parts[2] {
			case "available-teams":
				if r.Method == http.MethodGet {
					h.getAvailableTeams(w, r, challengeID)
					return
				}
			case "join":
				if r.Method == http.MethodPost {
					h.joinChallenge(w, r, challengeID)
					return
				}
			case "leave":
				if r.Method == http.MethodPost {
					h.leaveChallenge(w, r, challengeID)
					return
				}
			case "leaderboard":
				if r.Method == http.MethodGet {
					h.getLeaderboard(w, r, challengeID)
					return
				}
			case "activity":
				if r.Method == http.MethodGet {
					h.getActivity(w, r, challengeID)
					return
				}
			}
		}
	}

	writeError(w, http.StatusNotFound, "route not found")
}

func (h *ChallengesHandler) listChallenges(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user_id")
		return
	}

	response, err := h.service.ListChallenges(userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *ChallengesHandler) getChallengeDetails(w http.ResponseWriter, r *http.Request, challengeID string) {
	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user_id")
		return
	}

	response, err := h.service.GetChallengeDetails(userID, challengeID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *ChallengesHandler) getAvailableTeams(w http.ResponseWriter, r *http.Request, challengeID string) {
	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user_id")
		return
	}

	response, err := h.service.GetAvailableTeams(userID, challengeID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *ChallengesHandler) joinChallenge(w http.ResponseWriter, r *http.Request, challengeID string) {
	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user_id")
		return
	}

	var request models.JoinChallengeRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if request.ChatID == "" {
		writeError(w, http.StatusBadRequest, "chat_id is required")
		return
	}

	response, err := h.service.JoinChallenge(userID, challengeID, request.ChatID)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *ChallengesHandler) leaveChallenge(w http.ResponseWriter, r *http.Request, challengeID string) {
	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user_id")
		return
	}

	var request models.LeaveChallengeRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if request.TeamID == "" {
		writeError(w, http.StatusBadRequest, "team_id is required")
		return
	}

	response, err := h.service.LeaveChallenge(userID, challengeID, request.TeamID)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *ChallengesHandler) getLeaderboard(w http.ResponseWriter, r *http.Request, challengeID string) {
	userID, ok := userIDFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing user_id")
		return
	}

	response, err := h.service.GetLeaderboard(userID, challengeID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *ChallengesHandler) getActivity(w http.ResponseWriter, r *http.Request, challengeID string) {
	response, err := h.service.GetActivity(challengeID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *ChallengesHandler) handleWorkoutCompletedEvent(w http.ResponseWriter, r *http.Request) {
	var request models.WorkoutCompletedEventRequest

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.service.HandleWorkoutCompletedEvent(request); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{
		"status": "processed",
	})
}

func userIDFromRequest(r *http.Request) (int64, bool) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		return 0, false
	}

	if claims.UserID <= 0 {
		return 0, false
	}

	return int64(claims.UserID), true
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{
		"error": message,
	})
}