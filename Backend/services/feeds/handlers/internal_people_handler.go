package handlers

import (
	"encoding/json"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/alexandra-gritsaenko/gymbro-feeds/types"
)

type InternalPeopleHandler struct {
	store          store.PeopleStore
	internalSecret string
}

func NewInternalPeopleHandler(store store.PeopleStore) *InternalPeopleHandler {
	return &InternalPeopleHandler{
		store:          store,
		internalSecret: os.Getenv("INTERNAL_SERVICE_SECRET"),
	}
}

func (h *InternalPeopleHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if !h.isAuthorized(r) {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	switch {
	case r.Method == http.MethodGet &&
		strings.HasPrefix(r.URL.Path, "/internal/people/") &&
		strings.HasSuffix(r.URL.Path, "/following/ids"):
		h.GetFollowingIDs(w, r)
		return

	case r.Method == http.MethodGet &&
		strings.HasPrefix(r.URL.Path, "/internal/people/") &&
		strings.HasSuffix(r.URL.Path, "/friends/ids"):
		h.GetFriendIDs(w, r)
		return

	default:
		http.NotFound(w, r)
	}
}

func (h *InternalPeopleHandler) GetFollowingIDs(w http.ResponseWriter, r *http.Request) {
	userID, ok := internalUserIDFromPath(r.URL.Path, "/following/ids")
	if !ok {
		http.NotFound(w, r)
		return
	}

	ids, err := h.store.ListFollowingIDsForUserAny(userID)
	if err != nil {
		http.Error(w, "failed to load following ids", http.StatusInternalServerError)
		return
	}

	writeInternalIDs(w, ids)
}

func (h *InternalPeopleHandler) GetFriendIDs(w http.ResponseWriter, r *http.Request) {
	userID, ok := internalUserIDFromPath(r.URL.Path, "/friends/ids")
	if !ok {
		http.NotFound(w, r)
		return
	}

	ids, err := h.store.ListFriendIDsForUser(userID)
	if err != nil {
		http.Error(w, "failed to load friend ids", http.StatusInternalServerError)
		return
	}

	writeInternalIDs(w, ids)
}

func (h *InternalPeopleHandler) isAuthorized(r *http.Request) bool {
	if h.internalSecret == "" {
		return false
	}

	return r.Header.Get("X-Internal-Secret") == h.internalSecret
}

func internalUserIDFromPath(path string, suffix string) (int, bool) {
	path = strings.TrimSuffix(path, suffix)
	path = strings.TrimPrefix(path, "/internal/people/")
	path = strings.Trim(path, "/")

	userID, err := strconv.Atoi(path)
	if err != nil {
		return 0, false
	}

	return userID, true
}

func writeInternalIDs(w http.ResponseWriter, ids []int) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(types.InternalUserIDsResponse{
		UserIDs: ids,
	})
}