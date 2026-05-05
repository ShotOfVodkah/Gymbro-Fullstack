package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockPerksService struct {
	getDashboard      func(ctx context.Context, userID int64) (types.PerksDashboardResponse, error)
	getStreak         func(ctx context.Context, userID int64) (types.StreakResponse, error)
	updateWeeklyGoal  func(ctx context.Context, userID int64, goal int) (types.PerksDashboardResponse, error)
	useFreeze         func(ctx context.Context, userID int64) (types.PerksDashboardResponse, error)
	getAchievements   func(ctx context.Context, userID int64) ([]types.AchievementResponse, error)
	getLeaderboard    func(ctx context.Context, userID int64, filter string, sort string) ([]types.LeaderboardResponse, error)
	saveEvent         func(ctx context.Context, userID int64, req types.PerksEventRequest) error
}

func (m *mockPerksService) GetDashboard(ctx context.Context, userID int64) (types.PerksDashboardResponse, error) {
	return m.getDashboard(ctx, userID)
}
func (m *mockPerksService) GetStreak(ctx context.Context, userID int64) (types.StreakResponse, error) {
	return m.getStreak(ctx, userID)
}
func (m *mockPerksService) UpdateWeeklyGoal(ctx context.Context, userID int64, goal int) (types.PerksDashboardResponse, error) {
	return m.updateWeeklyGoal(ctx, userID, goal)
}
func (m *mockPerksService) UseStreakFreeze(ctx context.Context, userID int64) (types.PerksDashboardResponse, error) {
	return m.useFreeze(ctx, userID)
}
func (m *mockPerksService) GetAchievements(ctx context.Context, userID int64) ([]types.AchievementResponse, error) {
	return m.getAchievements(ctx, userID)
}
func (m *mockPerksService) GetLeaderboard(ctx context.Context, userID int64, filter string, sort string) ([]types.LeaderboardResponse, error) {
	return m.getLeaderboard(ctx, userID, filter, sort)
}
func (m *mockPerksService) SaveEvent(ctx context.Context, userID int64, req types.PerksEventRequest) error {
	return m.saveEvent(ctx, userID, req)
}

func withClaims(req *http.Request, userID int) *http.Request {
	return req.WithContext(authmw.ContextWithClaims(req.Context(), &authmw.Claims{UserID: userID}))
}

func TestPerksHandler_UnauthorizedWithoutClaims(t *testing.T) {
	h := NewPerksHandler(&mockPerksService{})

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/perks/me", nil)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestPerksHandler_MethodNotAllowed(t *testing.T) {
	h := NewPerksHandler(&mockPerksService{})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodPost, "/perks/me", nil), 1)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusMethodNotAllowed, rr.Code)
}

func TestPerksHandler_Events_BadJSON(t *testing.T) {
	h := NewPerksHandler(&mockPerksService{})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodPost, "/perks/events", bytes.NewBufferString("{bad json")), 1)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestPerksHandler_Events_MissingType(t *testing.T) {
	h := NewPerksHandler(&mockPerksService{})
	var buf bytes.Buffer
	_ = json.NewEncoder(&buf).Encode(types.PerksEventRequest{Type: ""})

	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodPost, "/perks/events", &buf), 1)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestPerksHandler_Dashboard_OK(t *testing.T) {
	h := NewPerksHandler(&mockPerksService{
		getDashboard: func(ctx context.Context, userID int64) (types.PerksDashboardResponse, error) {
			assert.Equal(t, int64(7), userID)
			return types.PerksDashboardResponse{}, nil
		},
	})

	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/perks/me", nil), 7)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestPerksHandler_Events_OK(t *testing.T) {
	h := NewPerksHandler(&mockPerksService{
		saveEvent: func(ctx context.Context, userID int64, req types.PerksEventRequest) error {
			assert.Equal(t, int64(7), userID)
			assert.Equal(t, "workout_completed", req.Type)
			return nil
		},
	})

	var buf bytes.Buffer
	require.NoError(t, json.NewEncoder(&buf).Encode(types.PerksEventRequest{Type: "workout_completed"}))
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodPost, "/perks/events", &buf), 7)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestPerksHandler_Dashboard_ServiceError(t *testing.T) {
	h := NewPerksHandler(&mockPerksService{
		getDashboard: func(ctx context.Context, userID int64) (types.PerksDashboardResponse, error) {
			return types.PerksDashboardResponse{}, errors.New("db down")
		},
	})

	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/perks/me", nil), 7)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusInternalServerError, rr.Code)
}

func TestInternalPerksHandler_ForbiddenWithoutSecret(t *testing.T) {
	t.Setenv("INTERNAL_SERVICE_SECRET", "s")
	h := NewInternalPerksHandler(&mockPerksService{
		saveEvent: func(ctx context.Context, userID int64, req types.PerksEventRequest) error { return nil },
	})

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/internal/perks/users/1/events", bytes.NewBufferString(`{}`))
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusForbidden, rr.Code)
}

func TestInternalPerksHandler_UserIDParsing(t *testing.T) {
	_, ok := internalUserIDFromPath("/internal/perks/users/abc/events")
	assert.False(t, ok)
	_, ok = internalUserIDFromPath("/internal/perks/users/123/events")
	assert.True(t, ok)
}

func TestInternalPerksHandler_BadJSON(t *testing.T) {
	t.Setenv("INTERNAL_SERVICE_SECRET", "s")
	h := NewInternalPerksHandler(&mockPerksService{
		saveEvent: func(ctx context.Context, userID int64, req types.PerksEventRequest) error { return nil },
	})

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/internal/perks/users/1/events", bytes.NewBufferString("{bad json"))
	req.Header.Set("X-Internal-Secret", "s")
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestInternalPerksHandler_MissingType(t *testing.T) {
	t.Setenv("INTERNAL_SERVICE_SECRET", "s")
	h := NewInternalPerksHandler(&mockPerksService{
		saveEvent: func(ctx context.Context, userID int64, req types.PerksEventRequest) error { return nil },
	})

	var buf bytes.Buffer
	require.NoError(t, json.NewEncoder(&buf).Encode(types.PerksEventRequest{}))

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/internal/perks/users/1/events", &buf)
	req.Header.Set("X-Internal-Secret", "s")
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestPerksHandler_NotFound(t *testing.T) {
	h := NewPerksHandler(&mockPerksService{})
	rr := httptest.NewRecorder()
	req := withClaims(httptest.NewRequest(http.MethodGet, "/perks/nope", nil), 1)
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestInternalPerksHandler_NotFoundRoute(t *testing.T) {
	t.Setenv("INTERNAL_SERVICE_SECRET", "s")
	h := NewInternalPerksHandler(&mockPerksService{
		saveEvent: func(ctx context.Context, userID int64, req types.PerksEventRequest) error { return nil },
	})
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/internal/perks/nope", nil)
	req.Header.Set("X-Internal-Secret", "s")
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}
