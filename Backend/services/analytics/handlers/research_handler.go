package handlers

import (
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-analytics/service"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
)

type ResearchHandler struct {
	researchService *service.ResearchService
}

func NewResearchHandler(store *store.AnalyticsStore) *ResearchHandler {
	return &ResearchHandler{
		researchService: service.NewResearchService(store),
	}
}

func (h *ResearchHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/research/social-vs-non-social":
		h.handleSocialVsNonSocial(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/research/sharing-vs-non-sharing":
		h.handleSharingVsNonSharing(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/research/workout-completion-engagement":
		h.handleWorkoutCompletionEngagement(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/research/errors-vs-dropoff":
		h.handleErrorsVsDropoff(w, r)
		return
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/research/feature-retention":
		h.handleFeatureRetention(w, r)
		return
	default:
		http.NotFound(w, r)
		return
	}
}

func (h *ResearchHandler) handleSocialVsNonSocial(w http.ResponseWriter, r *http.Request) {
	response, err := h.researchService.GetSocialVsNonSocial(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *ResearchHandler) handleSharingVsNonSharing(w http.ResponseWriter, r *http.Request) {
	response, err := h.researchService.GetSharingVsNonSharing(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *ResearchHandler) handleWorkoutCompletionEngagement(w http.ResponseWriter, r *http.Request) {
	response, err := h.researchService.GetWorkoutCompletionEngagement(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *ResearchHandler) handleErrorsVsDropoff(w http.ResponseWriter, r *http.Request) {
	response, err := h.researchService.GetErrorsVsDropoff(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *ResearchHandler) handleFeatureRetention(w http.ResponseWriter, r *http.Request) {
	response, err := h.researchService.GetFeatureRetention(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": err.Error(),
		})
		return
	}
	writeJSON(w, http.StatusOK, response)
}