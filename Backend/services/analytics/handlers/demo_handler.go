package handlers

import (
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-analytics/service"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type DemoHandler struct {
	demoService *service.DemoService
}

func NewDemoHandler(store *store.AnalyticsStore) *DemoHandler {
	return &DemoHandler{
		demoService: service.NewDemoService(store),
	}
}

func (h *DemoHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/demo/dashboard":
		h.handleDashboard(w, r)
		return
	default:
		http.NotFound(w, r)
		return
	}
}

func (h *DemoHandler) handleDashboard(w http.ResponseWriter, r *http.Request) {
	response, err := h.demoService.GetDashboard(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}