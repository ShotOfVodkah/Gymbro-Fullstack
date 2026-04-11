package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"regexp"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/jmoiron/sqlx"
)

var reSessionByID = regexp.MustCompile(`^/sessions/([^/]+)$`)

type sessionHandler struct {
	sessionStore store.SessionStore
	workoutStore store.WorkoutStorer
}

func NewSessionHandler(db *sqlx.DB) *sessionHandler {
	return &sessionHandler{
		sessionStore: store.NewSessionStore(db),
		workoutStore: store.NewWorkoutStore(db),
	}
}

func (h *sessionHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	if r.URL.Path == "/sessions/preview/batch" {
		if r.Method == http.MethodPost {
			h.GetSessionPreviewBatch(w, r)
		} else {
			notFound(w, r)
		}
		return
	}

	if m := reSessionByID.FindStringSubmatch(r.URL.Path); m != nil {
		if r.Method == http.MethodGet {
			h.GetSessionByID(w, r, m[1])
			return
		}
		notFound(w, r)
		return
	}

	if r.URL.Path == "/sessions" || r.URL.Path == "/sessions/" {
		switch r.Method {
		case http.MethodGet:
			h.ListSessionsByUser(w, r)
		case http.MethodPost:
			h.CreateSession(w, r)
		default:
			notFound(w, r)
		}
		return
	}

	notFound(w, r)
}

func (h *sessionHandler) GetSessionPreviewBatch(w http.ResponseWriter, r *http.Request) {
	var req types.SessionPreviewBatchRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}

	if len(req.IDs) == 0 {
		json.NewEncoder(w).Encode(types.SessionPreviewBatchResponse{
			Items: []types.SessionPreviewItem{},
		})
		return
	}

	items, err := h.sessionStore.GetSessionPreviewsByIDs(req.IDs)
	if err != nil {
		internalServerError(w, r)
		return
	}

	json.NewEncoder(w).Encode(types.SessionPreviewBatchResponse{
		Items: items,
	})
}

func (h *sessionHandler) GetSessionByID(w http.ResponseWriter, r *http.Request, id string) {
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	session, err := h.sessionStore.GetSessionByID(id)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	if session.UserID != userID {
		unauthorized(w, r)
		return
	}
	json.NewEncoder(w).Encode(session)
}

func (h *sessionHandler) ListSessionsByUser(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	var from, to *time.Time
	if s := r.URL.Query().Get("from"); s != "" {
		t, err := time.Parse(time.RFC3339, s)
		if err != nil {
			badRequest(w, r)
			return
		}
		from = &t
	}
	if s := r.URL.Query().Get("to"); s != "" {
		t, err := time.Parse(time.RFC3339, s)
		if err != nil {
			badRequest(w, r)
			return
		}
		to = &t
	}

	sessions, err := h.sessionStore.ListSessionsByUserID(userID, from, to)
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(sessions)
}

func (h *sessionHandler) CreateSession(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r)
	if !ok {
		unauthorized(w, r)
		return
	}

	var input types.SessionInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		badRequest(w, r)
		return
	}
	if input.ID == "" || input.WorkoutID == "" {
		badRequest(w, r)
		return
	}
	input.UserID = userID

	workout, err := h.workoutStore.GetWorkoutByID(input.WorkoutID)
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

	if err := h.sessionStore.InsertSession(&input); err != nil {
		internalServerError(w, r)
		return
	}

	session, err := h.sessionStore.GetSessionByID(input.ID)
	if err != nil {
		internalServerError(w, r)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(session)
}
