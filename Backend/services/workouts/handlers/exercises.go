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

// GET /exercises          → all exercises
// GET /exercises?type=    → filtered by type (strength / cardio / yoga)
func (h *exerciseHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	if r.Method != http.MethodGet {
		notFound(w, r)
		return
	}

	exerciseType := r.URL.Query().Get("type")

	if exerciseType == "" {
		exercises, err := h.exerciseStore.ListAll()
		if err != nil {
			internalServerError(w, r)
			return
		}
		json.NewEncoder(w).Encode(exercises)
		return
	}

	exercises, err := h.exerciseStore.ListByType(exerciseType)
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(exercises)
}
