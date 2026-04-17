package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/lib/pq"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockSessionStore struct {
	getByID       func(id string, locale string) (*types.WorkoutSession, error)
	insertSession func(*types.SessionInput) error
	listByUser    func(userID string, from, to *time.Time, locale string) ([]types.WorkoutSession, error)
	previews      func([]string, string) ([]types.SessionPreviewItem, error)
	calendar      func(userID, month string) ([]types.CalendarWorkoutDayResponse, error)
	ensure        func([]string) error
}

func (m *mockSessionStore) GetSessionByID(id string, locale string) (*types.WorkoutSession, error) {
	if m.getByID == nil {
		return nil, store.ErrNotFound
	}
	return m.getByID(id, locale)
}

func (m *mockSessionStore) InsertSession(input *types.SessionInput) error {
	if m.insertSession == nil {
		return nil
	}
	return m.insertSession(input)
}

func (m *mockSessionStore) ListSessionsByUserID(userID string, from, to *time.Time, locale string) ([]types.WorkoutSession, error) {
	if m.listByUser == nil {
		return nil, nil
	}
	return m.listByUser(userID, from, to, locale)
}

func (m *mockSessionStore) GetSessionPreviewsByIDs(ids []string, locale string) ([]types.SessionPreviewItem, error) {
	if m.previews == nil {
		return nil, nil
	}
	return m.previews(ids, locale)
}

func (m *mockSessionStore) ListCalendarSessionsByUserAndMonth(userID string, month string) ([]types.CalendarWorkoutDayResponse, error) {
	if m.calendar == nil {
		return nil, nil
	}
	return m.calendar(userID, month)
}

func (m *mockSessionStore) EnsureExercisesFromSessionDictionary(ids []string) error {
	if m.ensure == nil {
		return nil
	}
	return m.ensure(ids)
}

var _ store.SessionStorer = (*mockSessionStore)(nil)

func newSessionHandlerForTest(s store.SessionStorer, w store.WorkoutStorer) *sessionHandler {
	return &sessionHandler{sessionStore: s, workoutStore: w}
}

func doSessionRequest(h http.Handler, method, path string, body any) *httptest.ResponseRecorder {
	var buf bytes.Buffer
	if body != nil {
		json.NewEncoder(&buf).Encode(body)
	}
	req := httptest.NewRequest(method, path, &buf)
	req = req.WithContext(context.WithValue(req.Context(), testUserIDKey{}, "u1"))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	return rr
}

func TestSaveSessionAsWorkout_OK(t *testing.T) {
	sets := 3
	reps := 8
	sess := &types.WorkoutSession{
		ID:          "sess-1",
		UserID:      "u1",
		WorkoutName: "Ноги",
		WorkoutType: "strength",
		CompletedAt: time.Now().UTC(),
		Exercises: []types.SessionExercise{
			{ID: "squat", Name: "Присед", Type: "strength", MuscleGroup: "legs", Sets: &sets, Reps: &reps},
		},
	}

	var captured *types.WorkoutInput
	ms := &mockSessionStore{
		getByID: func(id string, _ string) (*types.WorkoutSession, error) {
			if id == "sess-1" {
				return sess, nil
			}
			return nil, store.ErrNotFound
		},
		ensure: func(ids []string) error {
			assert.Equal(t, []string{"squat"}, ids)
			return nil
		},
	}
	mw := &mockWorkoutStore{
		getByID: func(id string, _ string) (*types.Workout, error) {
			if captured != nil && id == captured.ID {
				ex := make([]types.Exercise, len(captured.Exercises))
				for i, e := range captured.Exercises {
					ex[i] = types.Exercise{
						ID: e.ExerciseID, Sets: e.Sets, Reps: e.Reps,
					}
				}
				return &types.Workout{
					ID: captured.ID, UserID: captured.UserID, Name: captured.Name, Type: captured.Type, Exercises: ex,
				}, nil
			}
			return nil, store.ErrNotFound
		},
		insert: func(input *types.WorkoutInput) error {
			captured = input
			return nil
		},
	}

	h := newSessionHandlerForTest(ms, mw)
	body := types.SaveSessionAsWorkoutRequest{SessionID: "sess-1"}
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", body)

	assert.Equal(t, http.StatusCreated, rr.Code)
	var got types.Workout
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	assert.Equal(t, "u1", got.UserID)
	assert.Equal(t, "Ноги", got.Name)
	assert.Equal(t, types.WorkoutTypeStrength, got.Type)
	require.Len(t, got.Exercises, 1)
	assert.Equal(t, "squat", got.Exercises[0].ID)

	require.NotNil(t, captured)
	assert.Equal(t, "u1", captured.UserID)
	assert.Equal(t, "squat", captured.Exercises[0].ExerciseID)
}

func TestSaveSessionAsWorkout_CustomNameAndWorkoutID(t *testing.T) {
	sess := &types.WorkoutSession{
		ID: "s1", UserID: "u1", WorkoutName: "Old", WorkoutType: "cardio",
		Exercises: []types.SessionExercise{},
	}
	var captured *types.WorkoutInput
	ms := &mockSessionStore{
		getByID: func(id string, _ string) (*types.WorkoutSession, error) { return sess, nil },
	}
	mw := &mockWorkoutStore{
		getByID: func(id string, _ string) (*types.Workout, error) {
			if captured != nil && id == captured.ID {
				return &types.Workout{ID: captured.ID, UserID: captured.UserID, Name: captured.Name, Type: captured.Type}, nil
			}
			return nil, store.ErrNotFound
		},
		insert: func(input *types.WorkoutInput) error {
			captured = input
			return nil
		},
	}
	h := newSessionHandlerForTest(ms, mw)
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", types.SaveSessionAsWorkoutRequest{
		SessionID: "s1", WorkoutID: "my-w", Name: "Новое имя",
	})
	assert.Equal(t, http.StatusCreated, rr.Code)
	require.NotNil(t, captured)
	assert.Equal(t, "my-w", captured.ID)
	assert.Equal(t, "Новое имя", captured.Name)
}

func TestSaveSessionAsWorkout_SessionNotFound(t *testing.T) {
	ms := &mockSessionStore{
		getByID: func(id string, _ string) (*types.WorkoutSession, error) { return nil, store.ErrNotFound },
	}
	h := newSessionHandlerForTest(ms, &mockWorkoutStore{})
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", types.SaveSessionAsWorkoutRequest{SessionID: "x"})
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestSaveSessionAsWorkout_OtherUsersSession_OK(t *testing.T) {
	sess := &types.WorkoutSession{
		ID: "s1", UserID: "other", WorkoutName: "Their leg day", WorkoutType: "strength", Exercises: nil,
	}
	var captured *types.WorkoutInput
	ms := &mockSessionStore{getByID: func(id string, _ string) (*types.WorkoutSession, error) { return sess, nil }}
	mw := &mockWorkoutStore{
		getByID: func(id string, _ string) (*types.Workout, error) {
			if captured != nil && id == captured.ID {
				return &types.Workout{ID: captured.ID, UserID: captured.UserID, Name: captured.Name, Type: captured.Type}, nil
			}
			return nil, store.ErrNotFound
		},
		insert: func(input *types.WorkoutInput) error {
			captured = input
			return nil
		},
	}
	h := newSessionHandlerForTest(ms, mw)
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", types.SaveSessionAsWorkoutRequest{SessionID: "s1"})
	assert.Equal(t, http.StatusCreated, rr.Code)
	require.NotNil(t, captured)
	assert.Equal(t, "u1", captured.UserID, "new workout belongs to caller, not session owner")
	assert.Equal(t, "Their leg day", captured.Name)
}

func TestSaveSessionAsWorkout_EmptySessionID(t *testing.T) {
	h := newSessionHandlerForTest(&mockSessionStore{}, &mockWorkoutStore{})
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", types.SaveSessionAsWorkoutRequest{})
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestSaveSessionAsWorkout_BadJSON(t *testing.T) {
	h := newSessionHandlerForTest(&mockSessionStore{}, &mockWorkoutStore{})
	req := httptest.NewRequest(http.MethodPost, "/sessions/save-as-workout", bytes.NewBufferString("{bad"))
	req = req.WithContext(context.WithValue(req.Context(), testUserIDKey{}, "u1"))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestSaveSessionAsWorkout_InvalidWorkoutType(t *testing.T) {
	sess := &types.WorkoutSession{
		ID: "s1", UserID: "u1", WorkoutType: "unknown", Exercises: []types.SessionExercise{},
	}
	ms := &mockSessionStore{getByID: func(id string, _ string) (*types.WorkoutSession, error) { return sess, nil }}
	h := newSessionHandlerForTest(ms, &mockWorkoutStore{})
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", types.SaveSessionAsWorkoutRequest{SessionID: "s1"})
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestSaveSessionAsWorkout_EnsureDictionaryError(t *testing.T) {
	sess := &types.WorkoutSession{
		ID: "s1", UserID: "u1", WorkoutType: "strength",
		Exercises: []types.SessionExercise{{ID: "ghost"}},
	}
	ms := &mockSessionStore{
		getByID: func(id string, _ string) (*types.WorkoutSession, error) { return sess, nil },
		ensure:  func([]string) error { return store.ErrInvalidExerciseDictionary },
	}
	h := newSessionHandlerForTest(ms, &mockWorkoutStore{})
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", types.SaveSessionAsWorkoutRequest{SessionID: "s1"})
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestSaveSessionAsWorkout_WorkoutIDConflict(t *testing.T) {
	sess := &types.WorkoutSession{
		ID: "s1", UserID: "u1", WorkoutType: "yoga", Exercises: []types.SessionExercise{},
	}
	ms := &mockSessionStore{getByID: func(id string, _ string) (*types.WorkoutSession, error) { return sess, nil }}
	mw := &mockWorkoutStore{
		getByID: func(id string, _ string) (*types.Workout, error) {
			if id == "existing" {
				return &types.Workout{ID: "existing", UserID: "u1"}, nil
			}
			return nil, store.ErrNotFound
		},
	}
	h := newSessionHandlerForTest(ms, mw)
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", types.SaveSessionAsWorkoutRequest{
		SessionID: "s1", WorkoutID: "existing",
	})
	assert.Equal(t, http.StatusConflict, rr.Code)
}

func TestSaveSessionAsWorkout_InsertUniqueViolation(t *testing.T) {
	sess := &types.WorkoutSession{
		ID: "s1", UserID: "u1", WorkoutType: "strength", Exercises: []types.SessionExercise{},
	}
	ms := &mockSessionStore{getByID: func(id string, _ string) (*types.WorkoutSession, error) { return sess, nil }}
	mw := &mockWorkoutStore{
		getByID: func(id string, _ string) (*types.Workout, error) { return nil, store.ErrNotFound },
		insert:  func(*types.WorkoutInput) error { return &pq.Error{Code: "23505"} },
	}
	h := newSessionHandlerForTest(ms, mw)
	rr := doSessionRequest(h, http.MethodPost, "/sessions/save-as-workout", types.SaveSessionAsWorkoutRequest{SessionID: "s1"})
	assert.Equal(t, http.StatusConflict, rr.Code)
}

func TestSaveSessionAsWorkout_WrongMethod(t *testing.T) {
	h := newSessionHandlerForTest(&mockSessionStore{}, &mockWorkoutStore{})
	rr := doSessionRequest(h, http.MethodGet, "/sessions/save-as-workout", nil)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestSaveSessionAsWorkout_UnauthorizedWithoutContext(t *testing.T) {
	h := newSessionHandlerForTest(&mockSessionStore{}, &mockWorkoutStore{})
	var buf bytes.Buffer
	json.NewEncoder(&buf).Encode(types.SaveSessionAsWorkoutRequest{SessionID: "s1"})
	req := httptest.NewRequest(http.MethodPost, "/sessions/save-as-workout", &buf)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}
