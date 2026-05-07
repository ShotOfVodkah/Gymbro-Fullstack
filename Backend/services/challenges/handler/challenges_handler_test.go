package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-challenges/models"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockChallengesService struct {
	listChallenges           func(userID int64) (*models.ChallengesListResponse, error)
	getChallengeDetails      func(userID int64, challengeID string) (*models.ChallengeDetailsResponse, error)
	getAvailableTeams        func(userID int64, challengeID string) (*models.AvailableChallengeTeamsResponse, error)
	joinChallenge            func(userID int64, challengeID string, chatID string) (*models.JoinChallengeResponse, error)
	leaveChallenge           func(userID int64, challengeID string, teamID string) (*models.LeaveChallengeResponse, error)
	getLeaderboard           func(userID int64, challengeID string) (*models.ChallengeLeaderboardResponse, error)
	getActivity              func(challengeID string) ([]models.ChallengeActivityResponse, error)
	handleWorkoutCompletedEv func(request models.WorkoutCompletedEventRequest) error
}

func (m *mockChallengesService) ListChallenges(userID int64) (*models.ChallengesListResponse, error) {
	if m.listChallenges == nil {
		return &models.ChallengesListResponse{Challenges: []models.ChallengeResponse{}}, nil
	}
	return m.listChallenges(userID)
}
func (m *mockChallengesService) GetChallengeDetails(userID int64, challengeID string) (*models.ChallengeDetailsResponse, error) {
	if m.getChallengeDetails == nil {
		return nil, errors.New("not implemented")
	}
	return m.getChallengeDetails(userID, challengeID)
}
func (m *mockChallengesService) GetAvailableTeams(userID int64, challengeID string) (*models.AvailableChallengeTeamsResponse, error) {
	if m.getAvailableTeams == nil {
		return &models.AvailableChallengeTeamsResponse{Teams: []models.AvailableChallengeTeamResponse{}}, nil
	}
	return m.getAvailableTeams(userID, challengeID)
}
func (m *mockChallengesService) JoinChallenge(userID int64, challengeID string, chatID string) (*models.JoinChallengeResponse, error) {
	if m.joinChallenge == nil {
		return nil, errors.New("not implemented")
	}
	return m.joinChallenge(userID, challengeID, chatID)
}
func (m *mockChallengesService) LeaveChallenge(userID int64, challengeID string, teamID string) (*models.LeaveChallengeResponse, error) {
	if m.leaveChallenge == nil {
		return nil, errors.New("not implemented")
	}
	return m.leaveChallenge(userID, challengeID, teamID)
}
func (m *mockChallengesService) GetLeaderboard(userID int64, challengeID string) (*models.ChallengeLeaderboardResponse, error) {
	if m.getLeaderboard == nil {
		return &models.ChallengeLeaderboardResponse{ChallengeID: challengeID, Leaderboard: []models.ChallengeLeaderboardTeamResponse{}}, nil
	}
	return m.getLeaderboard(userID, challengeID)
}
func (m *mockChallengesService) GetActivity(challengeID string) ([]models.ChallengeActivityResponse, error) {
	if m.getActivity == nil {
		return []models.ChallengeActivityResponse{}, nil
	}
	return m.getActivity(challengeID)
}
func (m *mockChallengesService) HandleWorkoutCompletedEvent(request models.WorkoutCompletedEventRequest) error {
	if m.handleWorkoutCompletedEv == nil {
		return nil
	}
	return m.handleWorkoutCompletedEv(request)
}
func (m *mockChallengesService) FinalizeExpiredChallenges() error { return nil }

func newReq(t *testing.T, method, path string, body any, userID int) *http.Request {
	t.Helper()
	var buf bytes.Buffer
	if body != nil {
		require.NoError(t, json.NewEncoder(&buf).Encode(body))
	}
	req := httptest.NewRequest(method, path, &buf)
	if userID > 0 {
		req = req.WithContext(authmw.ContextWithClaims(req.Context(), &authmw.Claims{UserID: userID}))
	}
	return req
}

func decodeErr(t *testing.T, rr *httptest.ResponseRecorder) string {
	t.Helper()
	var payload map[string]string
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&payload))
	return payload["error"]
}

func TestServeHTTP_NotFound(t *testing.T) {
	h := NewChallengesHandler(&mockChallengesService{})
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, newReq(t, http.MethodGet, "/nope", nil, 1))
	assert.Equal(t, http.StatusNotFound, rr.Code)
	assert.Equal(t, "route not found", decodeErr(t, rr))
}

func TestListChallenges_UnauthorizedWithoutClaims(t *testing.T) {
	h := NewChallengesHandler(&mockChallengesService{})
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, newReq(t, http.MethodGet, "/challenges", nil, 0))
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
	assert.Equal(t, "missing user_id", decodeErr(t, rr))
}

func TestListChallenges_OK(t *testing.T) {
	svc := &mockChallengesService{
		listChallenges: func(userID int64) (*models.ChallengesListResponse, error) {
			assert.Equal(t, int64(42), userID)
			return &models.ChallengesListResponse{
				Challenges: []models.ChallengeResponse{{ID: "c1", Title: "T"}},
			}, nil
		},
	}
	h := NewChallengesHandler(svc)

	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, newReq(t, http.MethodGet, "/challenges", nil, 42))

	assert.Equal(t, http.StatusOK, rr.Code)
	var got models.ChallengesListResponse
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	require.Len(t, got.Challenges, 1)
	assert.Equal(t, "c1", got.Challenges[0].ID)
}

func TestJoinChallenge_BadJSON(t *testing.T) {
	h := NewChallengesHandler(&mockChallengesService{})
	req := httptest.NewRequest(http.MethodPost, "/challenges/c1/join", bytes.NewBufferString("{bad json"))
	req = req.WithContext(authmw.ContextWithClaims(context.Background(), &authmw.Claims{UserID: 1}))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
	assert.Equal(t, "invalid request body", decodeErr(t, rr))
}

func TestJoinChallenge_MissingChatID(t *testing.T) {
	h := NewChallengesHandler(&mockChallengesService{})
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, newReq(t, http.MethodPost, "/challenges/c1/join", models.JoinChallengeRequest{ChatID: ""}, 1))
	assert.Equal(t, http.StatusBadRequest, rr.Code)
	assert.Equal(t, "chat_id is required", decodeErr(t, rr))
}

func TestJoinChallenge_ServiceErrorBecomesBadRequest(t *testing.T) {
	svc := &mockChallengesService{
		joinChallenge: func(userID int64, challengeID string, chatID string) (*models.JoinChallengeResponse, error) {
			return nil, errors.New("challenge is not active")
		},
	}
	h := NewChallengesHandler(svc)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, newReq(t, http.MethodPost, "/challenges/c1/join", models.JoinChallengeRequest{ChatID: "chat1"}, 1))
	assert.Equal(t, http.StatusBadRequest, rr.Code)
	assert.Equal(t, "challenge is not active", decodeErr(t, rr))
}

func TestJoinChallenge_OK(t *testing.T) {
	svc := &mockChallengesService{
		joinChallenge: func(userID int64, challengeID string, chatID string) (*models.JoinChallengeResponse, error) {
			assert.Equal(t, int64(1), userID)
			assert.Equal(t, "c1", challengeID)
			assert.Equal(t, "chat1", chatID)
			return &models.JoinChallengeResponse{TeamID: "team1", ChallengeID: "c1", ChatID: "chat1"}, nil
		},
	}
	h := NewChallengesHandler(svc)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, newReq(t, http.MethodPost, "/challenges/c1/join", models.JoinChallengeRequest{ChatID: "chat1"}, 1))
	assert.Equal(t, http.StatusOK, rr.Code)
	var got models.JoinChallengeResponse
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	assert.Equal(t, "team1", got.TeamID)
}

func TestInternalWorkoutCompleted_BadJSON(t *testing.T) {
	h := NewChallengesHandler(&mockChallengesService{})
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/internal/challenges/events/workout-completed", bytes.NewBufferString("{bad json"))
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
	assert.Equal(t, "invalid request body", decodeErr(t, rr))
}

func TestInternalWorkoutCompleted_ServiceErrorBecomesBadRequest(t *testing.T) {
	svc := &mockChallengesService{
		handleWorkoutCompletedEv: func(request models.WorkoutCompletedEventRequest) error {
			return errors.New("user_id is required")
		},
	}
	h := NewChallengesHandler(svc)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, newReq(t, http.MethodPost, "/internal/challenges/events/workout-completed", models.WorkoutCompletedEventRequest{}, 0))
	assert.Equal(t, http.StatusBadRequest, rr.Code)
	assert.Equal(t, "user_id is required", decodeErr(t, rr))
}

func TestInternalWorkoutCompleted_OK(t *testing.T) {
	var captured models.WorkoutCompletedEventRequest
	svc := &mockChallengesService{
		handleWorkoutCompletedEv: func(request models.WorkoutCompletedEventRequest) error {
			captured = request
			return nil
		},
	}
	h := NewChallengesHandler(svc)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, newReq(t, http.MethodPost, "/internal/challenges/events/workout-completed", models.WorkoutCompletedEventRequest{UserID: 7, SessionID: "s1"}, 0))
	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Equal(t, int64(7), captured.UserID)
	assert.Equal(t, "s1", captured.SessionID)
	var got map[string]string
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	assert.Equal(t, "processed", got["status"])
}

