package service

import (
	"errors"
	"testing"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-challenges/models"
	"github.com/alexandra-gritsaenko/gymbro-challenges/store"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockChallengeStore struct {
	listActiveTeamsForUser            func(userID int64) ([]models.ChallengeTeam, error)
	getChallengeByTeamID              func(teamID string) (*models.Challenge, error)
	createProgressEventAndUpdate      func(event models.ChallengeProgressEvent, userID int64, value int) (bool, *models.ChallengeTeam, error)
}

func (m *mockChallengeStore) ListChallenges() ([]models.Challenge, error)                                   { return nil, errors.New("not implemented") }
func (m *mockChallengeStore) GetChallenge(id string) (*models.Challenge, error)                            { return nil, errors.New("not implemented") }
func (m *mockChallengeStore) GetUserTeamForChallenge(challengeID string, userID int64) (*models.ChallengeTeam, error) {
	return nil, errors.New("not implemented")
}
func (m *mockChallengeStore) GetTeamByID(teamID string) (*models.ChallengeTeam, error)                     { return nil, errors.New("not implemented") }
func (m *mockChallengeStore) IsChatAlreadyJoined(challengeID string, chatID string) (bool, error)          { return false, errors.New("not implemented") }
func (m *mockChallengeStore) CreateTeam(team models.ChallengeTeam) error                                   { return errors.New("not implemented") }
func (m *mockChallengeStore) CreateTeamWithParticipants(team models.ChallengeTeam, participants []models.ChallengeParticipantStat) error {
	return errors.New("not implemented")
}
func (m *mockChallengeStore) UpdateTeamStatus(teamID string, status string) error                          { return errors.New("not implemented") }
func (m *mockChallengeStore) ListParticipants(challengeID string, teamID string) ([]models.ChallengeParticipantStat, error) {
	return nil, errors.New("not implemented")
}
func (m *mockChallengeStore) ListActivity(challengeID string) ([]models.ChallengeProgressEvent, error)     { return nil, errors.New("not implemented") }
func (m *mockChallengeStore) ListLeaderboard(challengeID string) ([]models.ChallengeTeam, error)           { return nil, errors.New("not implemented") }
func (m *mockChallengeStore) ListActiveTeamsForUser(userID int64) ([]models.ChallengeTeam, error) {
	if m.listActiveTeamsForUser == nil {
		return nil, nil
	}
	return m.listActiveTeamsForUser(userID)
}
func (m *mockChallengeStore) GetChallengeByTeamID(teamID string) (*models.Challenge, error) {
	if m.getChallengeByTeamID == nil {
		return nil, store.ErrNotFound
	}
	return m.getChallengeByTeamID(teamID)
}
func (m *mockChallengeStore) CreateProgressEventAndUpdateProgress(event models.ChallengeProgressEvent, userID int64, value int) (bool, *models.ChallengeTeam, error) {
	if m.createProgressEventAndUpdate == nil {
		return false, nil, nil
	}
	return m.createProgressEventAndUpdate(event, userID, value)
}
func (m *mockChallengeStore) FinalizeExpiredTeams() ([]models.ChallengeTeam, error)                         { return nil, errors.New("not implemented") }

func TestProgressValueForChallenge(t *testing.T) {
	t.Run("team_workouts_count", func(t *testing.T) {
		v, ok := progressValueForChallenge(models.Challenge{Type: "team_workouts_count"}, models.WorkoutCompletedEventRequest{})
		assert.True(t, ok)
		assert.Equal(t, 1, v)
	})

	t.Run("team_training_minutes_requires_duration", func(t *testing.T) {
		v, ok := progressValueForChallenge(models.Challenge{Type: "team_training_minutes"}, models.WorkoutCompletedEventRequest{DurationMinutes: 0})
		assert.False(t, ok)
		assert.Equal(t, 0, v)
	})

	t.Run("workout_category_requires_filter_match", func(t *testing.T) {
		filter := "yoga"
		v, ok := progressValueForChallenge(
			models.Challenge{Type: "workout_category", TargetFilter: &filter},
			models.WorkoutCompletedEventRequest{WorkoutType: "strength"},
		)
		assert.False(t, ok)
		assert.Equal(t, 0, v)

		v, ok = progressValueForChallenge(
			models.Challenge{Type: "workout_category", TargetFilter: &filter},
			models.WorkoutCompletedEventRequest{WorkoutType: "yoga"},
		)
		assert.True(t, ok)
		assert.Equal(t, 1, v)
	})
}

func TestHandleWorkoutCompletedEvent_ValidatesRequest(t *testing.T) {
	svc := NewChallengesService(&mockChallengeStore{}, nil, nil)

	err := svc.HandleWorkoutCompletedEvent(models.WorkoutCompletedEventRequest{UserID: 0, SessionID: "s1"})
	assert.Error(t, err)

	err = svc.HandleWorkoutCompletedEvent(models.WorkoutCompletedEventRequest{UserID: 1, SessionID: ""})
	assert.Error(t, err)
}

func TestHandleWorkoutCompletedEvent_CreatesProgressForActiveTeams(t *testing.T) {
	filter := "yoga"
	now := time.Now().UTC()

	storeMock := &mockChallengeStore{
		listActiveTeamsForUser: func(userID int64) ([]models.ChallengeTeam, error) {
			require.Equal(t, int64(10), userID)
			return []models.ChallengeTeam{
				{ID: "team-1", ChatID: "chat-1"},
				{ID: "team-2", ChatID: "chat-2"},
			}, nil
		},
		getChallengeByTeamID: func(teamID string) (*models.Challenge, error) {
			return &models.Challenge{ID: "c1", Type: "workout_category", Unit: "workouts", TargetFilter: &filter}, nil
		},
		createProgressEventAndUpdate: func(event models.ChallengeProgressEvent, userID int64, value int) (bool, *models.ChallengeTeam, error) {
			assert.Equal(t, int64(10), userID)
			assert.Equal(t, 1, value)
			assert.Equal(t, "workout_session", event.SourceType)
			assert.Equal(t, "sess-1", event.SourceID)
			assert.Equal(t, "c1", event.ChallengeID)
			assert.NotEmpty(t, event.TeamID)
			assert.NotEmpty(t, event.ID)
			assert.WithinDuration(t, now, event.CreatedAt, time.Second)
			return true, &models.ChallengeTeam{ID: event.TeamID, ChatID: "chat-x", Status: "in_progress"}, nil
		},
	}

	svc := NewChallengesService(storeMock, nil, nil)
	err := svc.HandleWorkoutCompletedEvent(models.WorkoutCompletedEventRequest{
		UserID:       10,
		SessionID:    "sess-1",
		WorkoutType:  "yoga",
		CompletedAt:  now.Format(time.RFC3339),
	})
	require.NoError(t, err)
}

