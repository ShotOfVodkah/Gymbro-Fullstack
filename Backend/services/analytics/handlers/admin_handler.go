package handlers

import (
	"net/http"
	"strings"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-analytics/service"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type AdminHandler struct {
	store *store.AnalyticsStore
}

func NewAdminHandler(store *store.AnalyticsStore) *AdminHandler {
	return &AdminHandler{store: store}
}

func (h *AdminHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodPost && r.URL.Path == "/analytics/admin/privacy/cleanup":
		h.handlePrivacyCleanup(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/admin/pipeline/overview":
		h.handlePipelineOverview(w, r)
		return
	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/analytics/admin/batches/"):
		h.handleBatchStatus(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/admin/invalid-events":
		h.handleInvalidEvents(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/admin/data-quality/summary":
		h.handleDataQualitySummary(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/admin/data-quality/app-versions":
		h.handleDataQualityByAppVersion(w, r)
		return
	case r.Method == http.MethodPost && r.URL.Path == "/analytics/admin/materialized-views/refresh":
		h.handleMaterializedViewsRefresh(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/admin/dashboard/overview-fast":
		h.handleDashboardOverviewFast(w, r)
		return
	default:
		http.NotFound(w, r)
		return
	}
}

func (h *AdminHandler) handlePrivacyCleanup(w http.ResponseWriter, r *http.Request) {
	if err := h.store.CleanupRawEvents(r.Context(), service.RawEventsRetentionDays); err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	if err := h.store.CleanupInvalidEvents(r.Context(), service.InvalidEventsRetentionDays); err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"status": "ok",
		"raw_events_retention_days": service.RawEventsRetentionDays,
		"invalid_events_retention_days": service.InvalidEventsRetentionDays,
	})
}

func (h *AdminHandler) handlePipelineOverview(w http.ResponseWriter, r *http.Request) {
	response, err := h.store.GetPipelineOverview(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *AdminHandler) handleBatchStatus(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/analytics/admin/batches/")
	path = strings.Trim(path, "/")

	if path == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "missing batch id"})
		return
	}

	response, err := h.store.GetBatchStatus(r.Context(), path)
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *AdminHandler) handleInvalidEvents(w http.ResponseWriter, r *http.Request) {
	limit := 20
	if raw := r.URL.Query().Get("limit"); raw != "" {
		parsed, err := strconv.Atoi(raw)
		if err == nil && parsed > 0 && parsed <= 200 {
			limit = parsed
		}
	}

	response, err := h.store.GetInvalidEvents(r.Context(), limit)
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *AdminHandler) handleDataQualitySummary(w http.ResponseWriter, r *http.Request) {
	response, err := h.store.GetDataQualityOverview(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	if response == nil {
		writeJSON(w, http.StatusOK, map[string]any{
			"message": "data quality summary is not available yet",
		})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *AdminHandler) handleDataQualityByAppVersion(w http.ResponseWriter, r *http.Request) {
	response, err := h.store.GetDataQualityByAppVersion(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *AdminHandler) handleMaterializedViewsRefresh(w http.ResponseWriter, r *http.Request) {
	if err := h.store.RefreshMaterializedViews(r.Context()); err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"status": "ok",
		"message": "materialized views refreshed",
	})
}

func (h *AdminHandler) handleDashboardOverviewFast(w http.ResponseWriter, r *http.Request) {
	response, err := h.store.GetDashboardOverviewFast(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	if response == nil {
		writeJSON(w, http.StatusOK, map[string]any{
			"message": "dashboard overview is not available yet",
		})
		return
	}
	writeJSON(w, http.StatusOK, response)
}