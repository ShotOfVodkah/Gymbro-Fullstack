package handlers

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// mockWorkoutStore реализует store.WorkoutStorer для тестов.
type mockWorkoutStore struct {
	getByID func(id string) (*types.Workout, error)
	listBy  func(userID string) ([]types.Workout, error)
	insert  func(input *types.WorkoutInput) error
	update  func(id string, input *types.WorkoutInput) error
	delete  func(id string) error
}

func (m *mockWorkoutStore) GetWorkoutByID(id string) (*types.Workout, error) {
	return m.getByID(id)
}
func (m *mockWorkoutStore) ListWorkoutsByUserID(userID string) ([]types.Workout, error) {
	return m.listBy(userID)
}
func (m *mockWorkoutStore) InsertWorkout(input *types.WorkoutInput) error {
	return m.insert(input)
}
func (m *mockWorkoutStore) UpdateWorkout(id string, input *types.WorkoutInput) error {
	return m.update(id, input)
}
func (m *mockWorkoutStore) DeleteWorkout(id string) error {
	return m.delete(id)
}

var _ store.WorkoutStorer = (*mockWorkoutStore)(nil)

func newHandler(m *mockWorkoutStore) *workoutHandler {
	return NewWorkoutHandler(m)
}

func ptr[T any](v T) *T { return &v }

// ─── helpers ────────────────────────────────────────────────────────────────

func doRequest(h http.Handler, method, path string, body any) *httptest.ResponseRecorder {
	var buf bytes.Buffer
	if body != nil {
		json.NewEncoder(&buf).Encode(body)
	}
	req := httptest.NewRequest(method, path, &buf)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	return rr
}

// ─── GetWorkoutByID ──────────────────────────────────────────────────────────

func TestGetWorkoutByID_OK(t *testing.T) {
	w := &types.Workout{ID: "w1", UserID: "u1", Name: "Test", Type: types.WorkoutTypeStrength, Exercises: []types.Exercise{}}
	h := newHandler(&mockWorkoutStore{
		getByID: func(id string) (*types.Workout, error) {
			assert.Equal(t, "w1", id)
			return w, nil
		},
	})

	rr := doRequest(h, http.MethodGet, "/workouts/w1", nil)

	assert.Equal(t, http.StatusOK, rr.Code)
	var got types.Workout
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	assert.Equal(t, "w1", got.ID)
	assert.Equal(t, "Test", got.Name)
}

func TestGetWorkoutByID_NotFound(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		getByID: func(id string) (*types.Workout, error) {
			return nil, store.ErrNotFound
		},
	})

	rr := doRequest(h, http.MethodGet, "/workouts/missing", nil)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestGetWorkoutByID_InternalError(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		getByID: func(id string) (*types.Workout, error) {
			return nil, errors.New("db down")
		},
	})

	rr := doRequest(h, http.MethodGet, "/workouts/w1", nil)
	assert.Equal(t, http.StatusInternalServerError, rr.Code)
}

// ─── ListWorkoutsByUser ───────────────────────────────────────────────────────

func TestListWorkoutsByUser_OK(t *testing.T) {
	workouts := []types.Workout{
		{ID: "w1", UserID: "u1", Name: "A", Type: types.WorkoutTypeCardio, Exercises: []types.Exercise{}},
		{ID: "w2", UserID: "u1", Name: "B", Type: types.WorkoutTypeYoga, Exercises: []types.Exercise{}},
	}
	h := newHandler(&mockWorkoutStore{
		listBy: func(userID string) ([]types.Workout, error) {
			assert.Equal(t, "u1", userID)
			return workouts, nil
		},
	})

	rr := doRequest(h, http.MethodGet, "/workouts?userId=u1", nil)

	assert.Equal(t, http.StatusOK, rr.Code)
	var got []types.Workout
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	assert.Len(t, got, 2)
}

func TestListWorkoutsByUser_MissingUserId(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	rr := doRequest(h, http.MethodGet, "/workouts", nil)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestListWorkoutsByUser_InternalError(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		listBy: func(userID string) ([]types.Workout, error) {
			return nil, errors.New("db down")
		},
	})

	rr := doRequest(h, http.MethodGet, "/workouts?userId=u1", nil)
	assert.Equal(t, http.StatusInternalServerError, rr.Code)
}

// ─── CreateWorkout ────────────────────────────────────────────────────────────

func TestCreateWorkout_OK(t *testing.T) {
	input := types.WorkoutInput{
		ID:     "w1",
		UserID: "u1",
		Name:   "My workout",
		Type:   types.WorkoutTypeStrength,
		Exercises: []types.WorkoutExerciseInput{
			{ExerciseID: "bench-press", Sets: ptr(3), Reps: ptr(10)},
		},
	}
	created := &types.Workout{
		ID:        "w1",
		UserID:    "u1",
		Name:      "My workout",
		Type:      types.WorkoutTypeStrength,
		Exercises: []types.Exercise{{ID: "bench-press", Name: "Жим лёжа"}},
	}
	h := newHandler(&mockWorkoutStore{
		insert: func(inp *types.WorkoutInput) error {
			assert.Equal(t, "w1", inp.ID)
			return nil
		},
		getByID: func(id string) (*types.Workout, error) {
			return created, nil
		},
	})

	rr := doRequest(h, http.MethodPost, "/workouts", input)

	assert.Equal(t, http.StatusCreated, rr.Code)
	var got types.Workout
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	assert.Equal(t, "w1", got.ID)
}

func TestCreateWorkout_BadJSON(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})
	req := httptest.NewRequest(http.MethodPost, "/workouts", bytes.NewBufferString("{bad json"))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCreateWorkout_MissingFields(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	rr := doRequest(h, http.MethodPost, "/workouts", types.WorkoutInput{ID: "w1"})
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCreateWorkout_InsertError(t *testing.T) {
	input := types.WorkoutInput{ID: "w1", UserID: "u1", Name: "X", Type: types.WorkoutTypeCardio}
	h := newHandler(&mockWorkoutStore{
		insert: func(inp *types.WorkoutInput) error {
			return errors.New("constraint violation")
		},
	})

	rr := doRequest(h, http.MethodPost, "/workouts", input)
	assert.Equal(t, http.StatusInternalServerError, rr.Code)
}

// ─── UpdateWorkout ────────────────────────────────────────────────────────────

func TestUpdateWorkout_OK(t *testing.T) {
	input := types.WorkoutInput{Name: "Updated", Type: types.WorkoutTypeYoga}
	updated := &types.Workout{ID: "w1", UserID: "u1", Name: "Updated", Type: types.WorkoutTypeYoga, Exercises: []types.Exercise{}}
	h := newHandler(&mockWorkoutStore{
		update: func(id string, inp *types.WorkoutInput) error {
			assert.Equal(t, "w1", id)
			assert.Equal(t, "Updated", inp.Name)
			return nil
		},
		getByID: func(id string) (*types.Workout, error) {
			return updated, nil
		},
	})

	rr := doRequest(h, http.MethodPut, "/workouts/w1", input)

	assert.Equal(t, http.StatusOK, rr.Code)
	var got types.Workout
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	assert.Equal(t, "Updated", got.Name)
}

func TestUpdateWorkout_MissingFields(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	rr := doRequest(h, http.MethodPut, "/workouts/w1", types.WorkoutInput{})
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestUpdateWorkout_NotFound(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		update: func(id string, inp *types.WorkoutInput) error {
			return store.ErrNotFound
		},
	})

	rr := doRequest(h, http.MethodPut, "/workouts/missing", types.WorkoutInput{Name: "X", Type: types.WorkoutTypeCardio})
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestUpdateWorkout_InternalError(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		update: func(id string, inp *types.WorkoutInput) error {
			return errors.New("db down")
		},
	})

	rr := doRequest(h, http.MethodPut, "/workouts/w1", types.WorkoutInput{Name: "X", Type: types.WorkoutTypeCardio})
	assert.Equal(t, http.StatusInternalServerError, rr.Code)
}

// ─── DeleteWorkout ────────────────────────────────────────────────────────────

func TestDeleteWorkout_OK(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		delete: func(id string) error {
			assert.Equal(t, "w1", id)
			return nil
		},
	})

	rr := doRequest(h, http.MethodDelete, "/workouts/w1", nil)

	assert.Equal(t, http.StatusOK, rr.Code)
	var got map[string]any
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
	assert.Equal(t, true, got["ok"])
	assert.Equal(t, "w1", got["id"])
}

func TestDeleteWorkout_NotFound(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		delete: func(id string) error { return store.ErrNotFound },
	})

	rr := doRequest(h, http.MethodDelete, "/workouts/missing", nil)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestDeleteWorkout_InternalError(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		delete: func(id string) error { return errors.New("db down") },
	})

	rr := doRequest(h, http.MethodDelete, "/workouts/w1", nil)
	assert.Equal(t, http.StatusInternalServerError, rr.Code)
}

// ─── CopyPremadeWorkout ───────────────────────────────────────────────────────

func TestCopyPremadeWorkout_OK(t *testing.T) {
	sets := 3
	reps := 10
	premade := &types.Workout{
		ID:     "premade-1",
		UserID: "premade",
		Name:   "Грудь и трицепс",
		Type:   types.WorkoutTypeStrength,
		Exercises: []types.Exercise{
			{ID: "bench-press", Name: "Жим лёжа", Sets: &sets, Reps: &reps},
		},
	}

	var capturedInput *types.WorkoutInput

	h := newHandler(&mockWorkoutStore{
		getByID: func(id string) (*types.Workout, error) {
			if id == "premade-1" {
				return premade, nil
			}
			// второй вызов — после InsertWorkout, возвращаем копию с новым id
			return &types.Workout{
				ID:        id,
				UserID:    "user-42",
				Name:      premade.Name,
				Type:      premade.Type,
				Exercises: premade.Exercises,
			}, nil
		},
		insert: func(input *types.WorkoutInput) error {
			capturedInput = input
			return nil
		},
	})

	body := copyPremadeRequest{UserID: "user-42", PremadeID: "premade-1"}
	rr := doRequest(h, http.MethodPost, "/workouts/copy-premade", body)

	assert.Equal(t, http.StatusCreated, rr.Code)

	var got types.Workout
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))

	assert.Equal(t, "user-42", got.UserID)
	assert.Equal(t, premade.Name, got.Name)
	assert.Equal(t, premade.Type, got.Type)

	require.NotNil(t, capturedInput)
	assert.NotEqual(t, "premade-1", capturedInput.ID, "новый ID не должен совпадать с premade ID")
	assert.Equal(t, "user-42", capturedInput.UserID)
	assert.Len(t, capturedInput.Exercises, 1)
	assert.Equal(t, "bench-press", capturedInput.Exercises[0].ExerciseID)
}

func TestCopyPremadeWorkout_PremadeNotFound(t *testing.T) {
	h := newHandler(&mockWorkoutStore{
		getByID: func(id string) (*types.Workout, error) {
			return nil, store.ErrNotFound
		},
	})

	body := copyPremadeRequest{UserID: "user-42", PremadeID: "premade-999"}
	rr := doRequest(h, http.MethodPost, "/workouts/copy-premade", body)

	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestCopyPremadeWorkout_BadRequest_MissingUserID(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	body := copyPremadeRequest{UserID: "", PremadeID: "premade-1"}
	rr := doRequest(h, http.MethodPost, "/workouts/copy-premade", body)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCopyPremadeWorkout_BadRequest_MissingPremadeID(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	body := copyPremadeRequest{UserID: "user-42", PremadeID: ""}
	rr := doRequest(h, http.MethodPost, "/workouts/copy-premade", body)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCopyPremadeWorkout_BadJSON(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	req := httptest.NewRequest(http.MethodPost, "/workouts/copy-premade", bytes.NewBufferString("{bad json"))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCopyPremadeWorkout_InsertError(t *testing.T) {
	premade := &types.Workout{
		ID: "premade-1", UserID: "premade", Name: "Ноги", Type: types.WorkoutTypeStrength,
		Exercises: []types.Exercise{},
	}
	h := newHandler(&mockWorkoutStore{
		getByID: func(id string) (*types.Workout, error) { return premade, nil },
		insert:  func(input *types.WorkoutInput) error { return errors.New("db down") },
	})

	body := copyPremadeRequest{UserID: "user-42", PremadeID: "premade-1"}
	rr := doRequest(h, http.MethodPost, "/workouts/copy-premade", body)

	assert.Equal(t, http.StatusInternalServerError, rr.Code)
}

func TestCopyPremadeWorkout_WrongMethod(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	rr := doRequest(h, http.MethodGet, "/workouts/copy-premade", nil)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

// ─── ServeHTTP dispatch ───────────────────────────────────────────────────────

func TestServeHTTP_UnknownPath(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	rr := doRequest(h, http.MethodGet, "/workouts/a/b/c", nil)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestServeHTTP_UnsupportedMethodOnList(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	rr := doRequest(h, http.MethodPatch, "/workouts", nil)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}

func TestServeHTTP_UnsupportedMethodOnByID(t *testing.T) {
	h := newHandler(&mockWorkoutStore{})

	rr := doRequest(h, http.MethodPatch, "/workouts/w1", nil)
	assert.Equal(t, http.StatusNotFound, rr.Code)
}
