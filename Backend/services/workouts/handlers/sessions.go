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
}

func NewSessionHandler(db *sqlx.DB) *sessionHandler {
	return &sessionHandler{
		sessionStore: store.NewSessionStore(db),
	}
}

func (h *sessionHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	// /sessions/{id}
	if m := reSessionByID.FindStringSubmatch(r.URL.Path); m != nil {
		if r.Method == http.MethodGet {
			h.GetSessionByID(w, r, m[1])
			return
		}
		notFound(w, r)
		return
	}

	// /sessions or /sessions/
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

func (h *sessionHandler) GetSessionByID(w http.ResponseWriter, r *http.Request, id string) {
	session, err := h.sessionStore.GetSessionByID(id)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(session)
}

func (h *sessionHandler) ListSessionsByUser(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("userId")
	if userID == "" {
		badRequest(w, r)
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
	var input types.SessionInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		badRequest(w, r)
		return
	}
	if input.ID == "" || input.UserID == "" || input.WorkoutID == "" {
		badRequest(w, r)
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
