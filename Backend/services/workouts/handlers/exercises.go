package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
	"github.com/jmoiron/sqlx"
)

type exerciseHandler struct {
	exerciseStore store.ExerciseStore
}

func NewExerciseHandler(db *sqlx.DB) *exerciseHandler {
	return &exerciseHandler{
		exerciseStore: store.NewExerciseStore(db),
	}
}

func (h *exerciseHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	if r.Method != http.MethodGet {
		notFound(w, r)
		return
	}

	exerciseType := r.URL.Query().Get("type")
	locale := requestLocale(r)

	if exerciseType == "" {
		exercises, err := h.exerciseStore.ListAll(locale)
		if err != nil {
			internalServerError(w, r)
			return
		}
		json.NewEncoder(w).Encode(exercises)
		return
	}

	exercises, err := h.exerciseStore.ListByType(exerciseType, locale)
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(exercises)
}
