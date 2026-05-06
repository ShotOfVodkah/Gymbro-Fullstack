package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-auth/types"
	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockUserService struct {
	list func() ([]types.User, error)
	get  func(email string) (*types.User, error)
}

func (m *mockUserService) ListUsers() ([]types.User, error) { return m.list() }
func (m *mockUserService) GetUserByEmail(email string) (*types.User, error) { return m.get(email) }

func withClaims(req *http.Request, c *authmw.Claims) *http.Request {
	return req.WithContext(authmw.ContextWithClaims(context.Background(), c))
}

func TestUsersHandler_ListUsers_UnauthorizedWithoutClaims(t *testing.T) {
	h := NewUserHandlerWithService(&mockUserService{})
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/users", nil)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestUsersHandler_ListUsers_ForbiddenForNonAdmin(t *testing.T) {
	h := NewUserHandlerWithService(&mockUserService{})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/users", nil), &authmw.Claims{UserID: 1, Role: "athlete"})
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestUsersHandler_ListUsers_OK_Admin(t *testing.T) {
	h := NewUserHandlerWithService(&mockUserService{
		list: func() ([]types.User, error) {
			return []types.User{{ID: 1, Email: "a@b.com"}}, nil
		},
	})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/users", nil), &authmw.Claims{UserID: 99, Role: "admin"})
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusOK, rr.Code)
	var got []map[string]any
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	require.Len(t, got, 1)
	assert.Equal(t, "a@b.com", got[0]["email"])
}

func TestUsersHandler_GetUser_SelfOK(t *testing.T) {
	h := NewUserHandlerWithService(&mockUserService{
		get: func(email string) (*types.User, error) {
			return &types.User{ID: 1, Email: email, Role: "athlete"}, nil
		},
	})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/users/me@example.com", nil), &authmw.Claims{UserID: 1, Email: "me@example.com", Role: "athlete"})
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestUsersHandler_GetUser_UnauthorizedForOtherUser(t *testing.T) {
	h := NewUserHandlerWithService(&mockUserService{})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/users/other@example.com", nil), &authmw.Claims{UserID: 1, Email: "me@example.com", Role: "athlete"})
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestUsersHandler_GetUser_AdminOK(t *testing.T) {
	h := NewUserHandlerWithService(&mockUserService{
		get: func(email string) (*types.User, error) {
			return &types.User{ID: 2, Email: email, Role: "coach"}, nil
		},
	})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/users/other@example.com", nil), &authmw.Claims{UserID: 99, Email: "admin@example.com", Role: "admin"})
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestUsersHandler_ListUsers_ServiceError500(t *testing.T) {
	h := NewUserHandlerWithService(&mockUserService{
		list: func() ([]types.User, error) { return nil, errors.New("db down") },
	})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/users", nil), &authmw.Claims{UserID: 99, Role: "admin"})
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusInternalServerError, rr.Code)
}

func TestUsersHandler_GetUser_NotFound(t *testing.T) {
	h := NewUserHandlerWithService(&mockUserService{
		get: func(email string) (*types.User, error) { return nil, errors.New("nope") },
	})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/users/miss@example.com", nil), &authmw.Claims{UserID: 99, Role: "admin"})
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

