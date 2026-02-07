package main

import (
	"encoding/json"
	"net/http"
	"regexp"
	"sync"
)


var (
	listUsersRe = regexp.MustCompile(`^\/users[\/]*$`)
	getUserRe = regexp.MustCompile(`^\/users\/(\d+)$`)
	createUserRe = regexp.MustCompile(`^\/users[\/]*$`)
)


func (h *userHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	switch {
		case r.Method == http.MethodGet && listUsersRe.MatchString(r.URL.Path):
			h.ListUsers(w, r)
			return
		case r.Method == http.MethodGet && getUserRe.MatchString(r.URL.Path):
			h.GetUser(w, r)
			return
		case r.Method == http.MethodPost && createUserRe.MatchString(r.URL.Path):
			h.CreateUser(w, r)
			return
		default:
			notFound(w, r)
			return
	}
}


func (h *userHandler) ListUsers(w http.ResponseWriter, r *http.Request) {
	users := make([]user, 0, len(h.store.m))
	h.store.RLock()
	for _, u := range h.store.m {
		users = append(users, u)
	}
	h.store.RUnlock()
	jsonBytes, err := json.Marshal(users)
	if err != nil {
		internalServerError(w, r)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write(jsonBytes)
}


func (h *userHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	matches := getUserRe.FindStringSubmatch(r.URL.Path)
	if len(matches) < 2 {
		notFound(w, r)
		return
	}
	h.store.RLock()
	user, ok := h.store.m[matches[1]]
	h.store.RUnlock()
	if !ok {
		notFound(w, r)
		return
	}
	jsonBytes, err := json.Marshal(user)
	if err != nil {
		internalServerError(w, r)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write(jsonBytes)
}


func (h *userHandler) CreateUser(w http.ResponseWriter, r *http.Request) {
	// u := user{}
	if !authorizer(h.key) (w, r) {
		unauthorized(w, r)
		return
	}
	var u user
	if err := json.NewDecoder(r.Body).Decode(&u); err != nil {
		badRequest(w, r)
		return
	}
	h.store.Lock()
	h.store.m[u.ID] = u
	h.store.Unlock()
	jsonBytes, err := json.Marshal(u)
	if err != nil {
		internalServerError(w, r)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write(jsonBytes)
}


func NewUserHandler() *userHandler {
	return &userHandler{
		store: &datastore{
			m: map[string]user{
				"1": {ID: "1", Name: "Sadie"},
				"2": {ID: "2", Name: "Kylie"},
			},
			RWMutex: &sync.RWMutex{},
		},
		key: secretKey,
	}
}