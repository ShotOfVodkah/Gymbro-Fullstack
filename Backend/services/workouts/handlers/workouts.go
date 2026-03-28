package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"regexp"

	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/jmoiron/sqlx"
)

var reWorkoutByID = regexp.MustCompile(`^/workouts/([^/]+)$`)

type workoutHandler struct {
	workoutStore store.WorkoutStore
}

func NewWorkoutHandler(db *sqlx.DB) *workoutHandler {
	return &workoutHandler{
		workoutStore: store.NewWorkoutStore(db),
	}
}

func (h *workoutHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	// /workouts/{id}
	if m := reWorkoutByID.FindStringSubmatch(r.URL.Path); m != nil {
		switch r.Method {
		case http.MethodGet:
			h.GetWorkoutByID(w, r, m[1])
		case http.MethodPut:
			h.UpdateWorkout(w, r, m[1])
		case http.MethodDelete:
			h.DeleteWorkout(w, r, m[1])
		default:
			notFound(w, r)
		}
		return
	}

	// /workouts/ or /workouts
	if r.URL.Path == "/workouts/" || r.URL.Path == "/workouts" {
		switch r.Method {
		case http.MethodGet:
			h.ListWorkoutsByUser(w, r)
		case http.MethodPost:
			h.CreateWorkout(w, r)
		default:
			notFound(w, r)
		}
		return
	}

	notFound(w, r)
}

func (h *workoutHandler) GetWorkoutByID(w http.ResponseWriter, r *http.Request, id string) {
	workout, err := h.workoutStore.GetWorkoutByID(id)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(workout)
}

func (h *workoutHandler) ListWorkoutsByUser(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("userId")
	if userID == "" {
		badRequest(w, r)
		return
	}
	workouts, err := h.workoutStore.ListWorkoutsByUserID(userID)
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(workouts)
}

func (h *workoutHandler) CreateWorkout(w http.ResponseWriter, r *http.Request) {
	var input types.WorkoutInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		badRequest(w, r)
		return
	}
	if input.ID == "" || input.UserID == "" || input.Name == "" || input.Type == "" {
		badRequest(w, r)
		return
	}
	if err := h.workoutStore.InsertWorkout(&input); err != nil {
		internalServerError(w, r)
		return
	}
	workout, err := h.workoutStore.GetWorkoutByID(input.ID)
	if err != nil {
		internalServerError(w, r)
		return
	}
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(workout)
}

func (h *workoutHandler) UpdateWorkout(w http.ResponseWriter, r *http.Request, id string) {
	var input types.WorkoutInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		badRequest(w, r)
		return
	}
	if input.Name == "" || input.Type == "" {
		badRequest(w, r)
		return
	}
	if err := h.workoutStore.UpdateWorkout(id, &input); err != nil {
		if errors.Is(err, store.ErrNotFound) {
			notFound(w, r)
			return
		}
		internalServerError(w, r)
		return
	}
	workout, err := h.workoutStore.GetWorkoutByID(id)
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(workout)
}

func (h *workoutHandler) DeleteWorkout(w http.ResponseWriter, r *http.Request, id string) {
	if err := h.workoutStore.DeleteWorkout(id); err != nil {
		if errors.Is(err, store.ErrNotFound) {
			notFound(w, r)
			return
		}
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(map[string]any{"ok": true, "id": id})
}
