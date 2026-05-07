package handlers

import (
	"encoding/json"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-perks/types"
)

type InternalPerksHandler struct {
	service        PerksService
	internalSecret string
}

func NewInternalPerksHandler(service PerksService) *InternalPerksHandler {
	return &InternalPerksHandler{
		service:        service,
		internalSecret: os.Getenv("INTERNAL_SERVICE_SECRET"),
	}
}

func (h *InternalPerksHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if !h.isAuthorized(r) {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	if r.Method == http.MethodPost &&
		strings.HasPrefix(r.URL.Path, "/internal/perks/users/") &&
		strings.HasSuffix(r.URL.Path, "/events") {
		h.handleUserEvent(w, r)
		return
	}

	http.NotFound(w, r)
}

func (h *InternalPerksHandler) handleUserEvent(w http.ResponseWriter, r *http.Request) {
	userID, ok := internalUserIDFromPath(r.URL.Path)
	if !ok {
		http.NotFound(w, r)
		return
	}

	var request types.PerksEventRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	if request.Type == "" {
		http.Error(w, "event type is required", http.StatusBadRequest)
		return
	}

	if err := h.service.SaveEvent(r.Context(), int64(userID), request); err != nil {
		http.Error(w, "failed to save perks event", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *InternalPerksHandler) isAuthorized(r *http.Request) bool {
	if h.internalSecret == "" {
		return false
	}

	return r.Header.Get("X-Internal-Secret") == h.internalSecret
}

func internalUserIDFromPath(path string) (int, bool) {
	path = strings.TrimPrefix(path, "/internal/perks/users/")
	path = strings.TrimSuffix(path, "/events")
	path = strings.Trim(path, "/")

	userID, err := strconv.Atoi(path)
	if err != nil {
		return 0, false
	}

	return userID, true
}