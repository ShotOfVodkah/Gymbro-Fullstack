package handlers

import (
	"encoding/json"
	"net/http"
	"regexp"

	"github.com/alexandra-gritsaenko/gymbro-auth/service"
	"github.com/alexandra-gritsaenko/gymbro-auth/types"
	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/jmoiron/sqlx"
)

var (
	listUsersRe = regexp.MustCompile(`^\/users[\/]*$`)
	getUserRe   = regexp.MustCompile(`^/users/([^/]+)$`)
)

type userHandler struct {
	service UserService
}

type UserService interface {
	ListUsers() ([]types.User, error)
	GetUserByEmail(email string) (*types.User, error)
}

func NewUserHandler(db *sqlx.DB) *userHandler {
	svc := service.NewUserService(db)
	return &userHandler{
		service: &svc,
	}
}

func NewUserHandlerWithService(svc UserService) *userHandler {
	return &userHandler{service: svc}
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
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		unauthorized(w, r)
		return
	}
	role := claims.Role

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
	claims, ok := authmw.GetClaims(r.Context())
	if !ok {
		unauthorized(w, r)
		return
	}
	currentUserEmail := claims.Email
	role := claims.Role

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
