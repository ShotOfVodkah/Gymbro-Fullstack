package handlers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-analytics/service"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type QueryHandler struct {
	queryService *service.QueryService
}

func NewQueryHandler(store *store.AnalyticsStore) *QueryHandler {
	return &QueryHandler{
		queryService: service.NewQueryService(store),
	}
}

func (h *QueryHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/metrics/overview":
		h.handleOverview(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/metrics/errors":
		h.handleErrors(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/screens":
		h.handleScreens(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/events/top":
		h.handleTopEvents(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/features/usage":
		h.handleFeatureUsage(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/funnels/workout-share":
		h.handleWorkoutShareFunnel(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/funnels/registration-to-first-workout":
		h.handleRegistrationToFirstWorkoutFunnel(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/funnels/feeds-open-to-interaction":
		h.handleFeedsOpenToInteractionFunnel(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/funnels/profile-open-to-relationship-action":
		h.handleProfileOpenToRelationshipActionFunnel(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/retention/cohorts":
		h.handleRetentionCohorts(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/app-versions":
		h.handleAppVersions(w, r)
		return
	case r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/analytics/users/") && strings.HasSuffix(r.URL.Path, "/summary"):
		h.handleUserSummary(w, r)
		return
	default:
		http.NotFound(w, r)
		return
	}
}

func (h *QueryHandler) handleOverview(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetOverview(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleErrors(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetErrors(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleScreens(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetScreens(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleTopEvents(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetTopEvents(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleFeatureUsage(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetFeatureUsage(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleWorkoutShareFunnel(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetWorkoutShareFunnel(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleRegistrationToFirstWorkoutFunnel(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetRegistrationToFirstWorkoutFunnel(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleFeedsOpenToInteractionFunnel(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetFeedsOpenToInteractionFunnel(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleProfileOpenToRelationshipActionFunnel(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetProfileOpenToRelationshipActionFunnel(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleRetentionCohorts(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetRetentionCohorts(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleAppVersions(w http.ResponseWriter, r *http.Request) {
	response, err := h.queryService.GetAppVersions(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *QueryHandler) handleUserSummary(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/analytics/users/")
	path = strings.TrimSuffix(path, "/summary")
	path = strings.Trim(path, "/")

	userID, err := strconv.ParseInt(path, 10, 64)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": "invalid user id",
		})
		return
	}

	response, err := h.queryService.GetUserSummary(r.Context(), userID)
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}