package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"net/http"
	"regexp"

	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
)

func newID() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

type copyPremadeRequest struct {
	PremadeID string `json:"premadeId"`
}

var reWorkoutByID = regexp.MustCompile(`^/workouts/([^/]+)$`)

type workoutHandler struct {
	workoutStore store.WorkoutStorer
}

func NewWorkoutHandler(s store.WorkoutStorer) *workoutHandler {
	return &workoutHandler{workoutStore: s}
}

func (h *workoutHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	if r.URL.Path == "/workouts/copy-premade" {
		if r.Method == http.MethodPost {
			h.CopyPremadeWorkout(w, r)
		} else {
			notFound(w, r)
		}
		return
	}

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
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	workout, err := h.workoutStore.GetWorkoutByID(id)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	if workout.UserID != userID {
		unauthorized(w, r)
		return
	}
	json.NewEncoder(w).Encode(workout)
}

func (h *workoutHandler) ListWorkoutsByUser(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
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
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	var input types.WorkoutInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		badRequest(w, r)
		return
	}
	if input.ID == "" || input.Name == "" || input.Type == "" {
		badRequest(w, r)
		return
	}
	input.UserID = userID
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
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	var input types.WorkoutInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		badRequest(w, r)
		return
	}
	if input.Name == "" || input.Type == "" {
		badRequest(w, r)
		return
	}
	current, err := h.workoutStore.GetWorkoutByID(id)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	if current.UserID != userID {
		unauthorized(w, r)
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
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	current, err := h.workoutStore.GetWorkoutByID(id)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	if current.UserID != userID {
		unauthorized(w, r)
		return
	}

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

func (h *workoutHandler) CopyPremadeWorkout(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	var req copyPremadeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}
	if req.PremadeID == "" {
		badRequest(w, r)
		return
	}

	premade, err := h.workoutStore.GetWorkoutByID(req.PremadeID)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}

	exercises := make([]types.WorkoutExerciseInput, len(premade.Exercises))
	for i, ex := range premade.Exercises {
		exercises[i] = types.WorkoutExerciseInput{
			ExerciseID:      ex.ID,
			Sets:            ex.Sets,
			Reps:            ex.Reps,
			WeightKg:        ex.WeightKg,
			DurationMinutes: ex.DurationMinutes,
			Pace:            ex.Pace,
			HoldSeconds:     ex.HoldSeconds,
			BreathCount:     ex.BreathCount,
		}
	}

	newID := newID()
	input := types.WorkoutInput{
		ID:        newID,
		UserID:    userID,
		Name:      premade.Name,
		Type:      premade.Type,
		Exercises: exercises,
	}

	if err := h.workoutStore.InsertWorkout(&input); err != nil {
		internalServerError(w, r)
		return
	}

	workout, err := h.workoutStore.GetWorkoutByID(newID)
	if err != nil {
		internalServerError(w, r)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(workout)
}
