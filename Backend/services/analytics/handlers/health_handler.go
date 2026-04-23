package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-analytics/service"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type HealthHandler struct {
	healthService *service.HealthService
}

func NewHealthHandler(store *store.HealthStore) *HealthHandler {
	return &HealthHandler{
		healthService: service.NewHealthService(store),
	}
}

func (h *HealthHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.URL.Path {
	case "/analytics/health":
		h.handleHealth(w, r)
	case "/analytics/ready":
		h.handleReady(w, r)
	default:
		http.NotFound(w, r)
	}
}

func (h *HealthHandler) handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, h.healthService.Health())
}

func (h *HealthHandler) handleReady(w http.ResponseWriter, r *http.Request) {
	if err := h.healthService.Ready(); err != nil {
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{
			"status":  "not_ready",
			"service": "analytics_service",
		})
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{
		"status":  "ready",
		"service": "analytics_service",
	})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}