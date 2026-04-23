package handlers

import (
	"encoding/json"
	"net/http"

	authmw "github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/service"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type AnalyticsHandler struct {
	analyticsService *service.AnalyticsService
}

func NewAnalyticsHandler(store *store.AnalyticsStore) *AnalyticsHandler {
	return &AnalyticsHandler{
		analyticsService: service.NewAnalyticsService(store),
	}
}

func (h *AnalyticsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodPost && (r.URL.Path == "/analytics/events" || r.URL.Path == "/analytics/events/batch"):
		h.handleEventsBatch(w, r)
		return
	default:
		http.NotFound(w, r)
		return
	}
}

func (h *AnalyticsHandler) handleEventsBatch(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		writeJSON(w, http.StatusUnauthorized, map[string]string{
			"error": "unauthorized",
		})
		return
	}

	requestID := getOrCreateRequestID(r)

	var events []models.AnalyticsEventDTO
	if err := json.NewDecoder(r.Body).Decode(&events); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": "invalid request body",
		})
		return
	}

	response, err := h.analyticsService.IngestBatch(
		r.Context(),
		requestID,
		int64(claims.UserID),
		events,
	)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}