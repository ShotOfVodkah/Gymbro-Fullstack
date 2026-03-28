package store

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/jmoiron/sqlx"
)

var ErrNotFound = errors.New("not found")

type WorkoutStore struct {
	db *sqlx.DB
}

func NewWorkoutStore(db *sqlx.DB) WorkoutStore {
	return WorkoutStore{db: db}
}

type workoutRow struct {
	ID            string `db:"id"`
	UserID        string `db:"user_id"`
	Name          string `db:"name"`
	Type          string `db:"type"`
	ExercisesJSON []byte `db:"exercises"`
}

func rowToWorkout(row workoutRow) (*types.Workout, error) {
	var exercises []types.Exercise
	if err := json.Unmarshal(row.ExercisesJSON, &exercises); err != nil {
		return nil, fmt.Errorf("unmarshal exercises: %w", err)
	}
	return &types.Workout{
		ID:        row.ID,
		UserID:    row.UserID,
		Name:      row.Name,
		Type:      types.WorkoutType(row.Type),
		Exercises: exercises,
	}, nil
}

func (ws *WorkoutStore) GetWorkoutByID(id string) (*types.Workout, error) {
	var row workoutRow
	err := ws.db.Get(&row, `SELECT id, user_id, name, type, exercises FROM workouts WHERE id = $1`, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("GetWorkoutByID: %w", err)
	}
	return rowToWorkout(row)
}

func (ws *WorkoutStore) ListWorkoutsByUserID(userID string) ([]types.Workout, error) {
	var rows []workoutRow
	err := ws.db.Select(&rows, `SELECT id, user_id, name, type, exercises FROM workouts WHERE user_id = $1 ORDER BY id`, userID)
	if err != nil {
		return nil, fmt.Errorf("ListWorkoutsByUserID: %w", err)
	}

	workouts := make([]types.Workout, 0, len(rows))
	for _, row := range rows {
		w, err := rowToWorkout(row)
		if err != nil {
			return nil, err
		}
		workouts = append(workouts, *w)
	}
	return workouts, nil
}

func (ws *WorkoutStore) InsertWorkout(w *types.Workout) error {
	exercisesJSON, err := json.Marshal(w.Exercises)
	if err != nil {
		return fmt.Errorf("InsertWorkout marshal: %w", err)
	}
	_, err = ws.db.Exec(
		`INSERT INTO workouts (id, user_id, name, type, exercises) VALUES ($1, $2, $3, $4, $5)`,
		w.ID, w.UserID, w.Name, string(w.Type), exercisesJSON,
	)
	if err != nil {
		return fmt.Errorf("InsertWorkout: %w", err)
	}
	return nil
}

func (ws *WorkoutStore) UpdateWorkout(id string, w *types.Workout) error {
	exercisesJSON, err := json.Marshal(w.Exercises)
	if err != nil {
		return fmt.Errorf("UpdateWorkout marshal: %w", err)
	}
	res, err := ws.db.Exec(
		`UPDATE workouts SET name = $1, type = $2, exercises = $3 WHERE id = $4`,
		w.Name, string(w.Type), exercisesJSON, id,
	)
	if err != nil {
		return fmt.Errorf("UpdateWorkout: %w", err)
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return ErrNotFound
	}
	return nil
}

func (ws *WorkoutStore) DeleteWorkout(id string) error {
	res, err := ws.db.Exec(`DELETE FROM workouts WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("DeleteWorkout: %w", err)
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return ErrNotFound
	}
	return nil
}
