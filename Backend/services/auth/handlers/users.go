package handlers

import (
	"encoding/json"
	"net/http"
	"regexp"

	"github.com/alexandra-gritsaenko/gymbro-auth/service"
	"github.com/jmoiron/sqlx"
)

var (
	listUsersRe  = regexp.MustCompile(`^\/users[\/]*$`)
	getUserRe    = regexp.MustCompile(`^/users/([^/]+)$`)
)

type userHandler struct {
	service service.UserService
}

func NewUserHandler(db *sqlx.DB) *userHandler {
	return &userHandler{
		service: service.NewUserService(db),
	}
}

func (h *userHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	switch {
	case r.Method == http.MethodGet && listUsersRe.MatchString(r.URL.Path):
		h.ListUsers(w, r)
		return
	case r.Method == http.MethodGet && getUserRe.MatchString(r.URL.Path):
		h.GetUser(w, r)
		return
	default:
		notFound(w, r)
		return
	}
}

func (h *userHandler) ListUsers(w http.ResponseWriter, r *http.Request) {
	roleVal := r.Context().Value(ContextRoleKey)
	if roleVal == nil {
		unauthorized(w, r)
		return
	}
	role := roleVal.(string)

	if role != "admin" {
		unauthorized(w, r)
		return
	}

	users, err := h.service.ListUsers()
	if err != nil {
		internalServerError(w, r)
		return
	}

	type userResponse struct {
		ID    int    `json:"id"`
		Email string `json:"email"`
	}

	resp := make([]userResponse, 0, len(users))
	for _, u := range users {
		resp = append(resp, userResponse{
			ID:    u.ID,
			Email: u.Email,
		})
	}

	json.NewEncoder(w).Encode(resp)
}

func (h *userHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	matches := getUserRe.FindStringSubmatch(r.URL.Path)
	if len(matches) < 2 {
		notFound(w, r)
		return
	}

	requestEmail := matches[1]
	emailVal := r.Context().Value(ContextEmailKey)
	roleVal := r.Context().Value(ContextRoleKey)
	if emailVal == nil || roleVal == nil {
		unauthorized(w, r)
		return
	}
	currentUserEmail := emailVal.(string)
	role := roleVal.(string)

	if role != "admin" && requestEmail != currentUserEmail {
		unauthorized(w, r)
		return
	}

	user, err := h.service.GetUserByEmail(requestEmail)
	if err != nil {
		notFound(w, r)
		return
	}

	json.NewEncoder(w).Encode(struct {
		ID    int    `json:"id"`
		Email string `json:"email"`
		Role  string `json:"role"`
	}{
		ID:    user.ID,
		Email: user.Email,
		Role:  user.Role,
	})
}
