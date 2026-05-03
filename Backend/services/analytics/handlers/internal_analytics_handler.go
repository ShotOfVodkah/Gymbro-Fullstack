package handlers

import (
	"encoding/json"
	"net/http"
	"os"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type InternalAnalyticsHandler struct {
	analyticsStore *store.AnalyticsStore
	secret         string
}

func NewInternalAnalyticsHandler(analyticsStore *store.AnalyticsStore) *InternalAnalyticsHandler {
	return &InternalAnalyticsHandler{
		analyticsStore: analyticsStore,
		secret:         os.Getenv("INTERNAL_SERVICE_SECRET"),
	}
}

func (h *InternalAnalyticsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Header.Get("X-Internal-Secret") != h.secret {
		writeJSON(w, http.StatusForbidden, map[string]string{
			"error": "forbidden",
		})
		return
	}

	switch {
	case r.Method == http.MethodPost && r.URL.Path == "/internal/analytics/events":
		h.handleEvent(w, r)
		return
	default:
		http.NotFound(w, r)
		return
	}
}

func (h *InternalAnalyticsHandler) handleEvent(w http.ResponseWriter, r *http.Request) {
	var request models.InternalAnalyticsEventRequest

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": "invalid request body",
		})
		return
	}

	if request.EventName == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": "event_name is required",
		})
		return
	}

	timestamp := time.Now()
	if request.Timestamp != "" {
		if parsed, err := time.Parse(time.RFC3339, request.Timestamp); err == nil {
			timestamp = parsed
		}
	}

	event := models.AnalyticsEventDTO{
		EventName:  request.EventName,
		Properties: request.Properties,
		Timestamp:  timestamp,
		SessionID:  "backend",
		UserID:     "0",
		Platform:   request.Platform,
		AppVersion: "backend",
	}

	response, err := NewAnalyticsHandler(h.analyticsStore).analyticsService.IngestBatch(
		r.Context(),
		getOrCreateRequestID(r),
		0,
		[]models.AnalyticsEventDTO{event},
	)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}