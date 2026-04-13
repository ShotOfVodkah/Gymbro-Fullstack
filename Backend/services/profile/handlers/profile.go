package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"regexp"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-profile/store"
	"github.com/alexandra-gritsaenko/gymbro-profile/types"
)

var reProfileByID = regexp.MustCompile(`^/profiles/([0-9]+)$`)

type ProfileHandler struct {
	store store.ProfileStore
}

func NewProfileHandler(store store.ProfileStore) *ProfileHandler {
	return &ProfileHandler{store: store}
}

func (h *ProfileHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	if r.URL.Path == "/profiles/batch" {
		if r.Method == http.MethodPost {
			h.GetProfilesBatch(w, r)
			return
		}
		notFound(w, r)
		return
	}

	if r.URL.Path == "/profiles" {
		if r.Method == http.MethodGet {
			h.ListProfiles(w, r)
			return
		}
		notFound(w, r)
		return
	}

	if m := reProfileByID.FindStringSubmatch(r.URL.Path); m != nil {
		if r.Method == http.MethodGet {
			h.GetProfileByID(w, r, m[1])
			return
		}
		notFound(w, r)
		return
	}

	notFound(w, r)
}

func (h *ProfileHandler) GetProfileByID(w http.ResponseWriter, r *http.Request, userIDStr string) {
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		badRequest(w, r)
		return
	}

	profile, err := h.store.GetByUserID(userID)
	if errors.Is(err, store.ErrNotFound) {
		notFound(w, r)
		return
	}
	if err != nil {
		internalServerError(w, r)
		return
	}

	json.NewEncoder(w).Encode(profile)
}

func (h *ProfileHandler) GetProfilesBatch(w http.ResponseWriter, r *http.Request) {
	var req types.BatchProfilesRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}

	if len(req.IDs) == 0 {
		json.NewEncoder(w).Encode([]types.Profile{})
		return
	}

	profiles, err := h.store.ListByUserIDs(req.IDs)
	if err != nil {
		internalServerError(w, r)
		return
	}

	json.NewEncoder(w).Encode(profiles)
}

func (h *ProfileHandler) ListProfiles(w http.ResponseWriter, r *http.Request) {
	profiles, err := h.store.ListAll()
	if err != nil {
		internalServerError(w, r)
		return
	}
	json.NewEncoder(w).Encode(profiles)
}