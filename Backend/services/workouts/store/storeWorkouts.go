package store

import (
	"database/sql"
	"errors"
	"fmt"

	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/jmoiron/sqlx"
)

var ErrNotFound = errors.New("not found")

type WorkoutStorer interface {
	GetWorkoutByID(id string) (*types.Workout, error)
	ListWorkoutsByUserID(userID string) ([]types.Workout, error)
	InsertWorkout(input *types.WorkoutInput) error
	UpdateWorkout(id string, input *types.WorkoutInput) error
	DeleteWorkout(id string) error
}

type WorkoutStore struct {
	db *sqlx.DB
}

func NewWorkoutStore(db *sqlx.DB) *WorkoutStore {
	return &WorkoutStore{db: db}
}

type workoutRow struct {
	ID     string `db:"id"`
	UserID string `db:"user_id"`
	Name   string `db:"name"`
	Type   string `db:"type"`
}

type workoutExerciseRow struct {
	ExerciseID  string `db:"exercise_id"`
	Name        string `db:"name"`
	ExType      string `db:"ex_type"`
	MuscleGroup string `db:"muscle_group"`
	Sets            *int     `db:"sets"`
	Reps            *int     `db:"reps"`
	WeightKg        *float64 `db:"weight_kg"`
	DurationMinutes *int     `db:"duration_minutes"`
	Pace            *string  `db:"pace"`
	HoldSeconds     *int     `db:"hold_seconds"`
	BreathCount     *int     `db:"breath_count"`
}

func rowToExercise(r workoutExerciseRow) types.Exercise {
	return types.Exercise{
		ID:              r.ExerciseID,
		Name:            r.Name,
		Type:            r.ExType,
		MuscleGroup:     r.MuscleGroup,
		Sets:            r.Sets,
		Reps:            r.Reps,
		WeightKg:        r.WeightKg,
		DurationMinutes: r.DurationMinutes,
		Pace:            r.Pace,
		HoldSeconds:     r.HoldSeconds,
		BreathCount:     r.BreathCount,
	}
}

type workoutPreviewRow struct {
	ID              string `db:"id"`
	Title           string `db:"title"`
	Category        string `db:"category"`
	DurationMinutes int    `db:"duration_minutes"`
	ExerciseCount   int    `db:"exercise_count"`
}

type workoutPreviewExerciseRow struct {
	WorkoutID       string   `db:"workout_id"`
	ExerciseID      string   `db:"exercise_id"`
	Name            string   `db:"name"`
	Type            string   `db:"type"`
	MuscleGroup     string   `db:"muscle_group"`
	Position        int      `db:"position"`
	Sets            *int     `db:"sets"`
	Reps            *int     `db:"reps"`
	WeightKg        *float64 `db:"weight_kg"`
	DurationMinutes *int     `db:"duration_minutes"`
	Pace            *string  `db:"pace"`
	HoldSeconds     *int     `db:"hold_seconds"`
	BreathCount     *int     `db:"breath_count"`
}

const exerciseJoinQuery = `
	SELECT
		we.exercise_id,
		e.name,
		e.type        AS ex_type,
		e.muscle_group,
		we.sets,
		we.reps,
		we.weight_kg,
		we.duration_minutes,
		we.pace,
		we.hold_seconds,
		we.breath_count
	FROM workout_exercises we
	JOIN exercises e ON e.id = we.exercise_id
	WHERE we.workout_id = $1
	ORDER BY we.position
`

func (ws *WorkoutStore) loadExercises(workoutID string) ([]types.Exercise, error) {
	var rows []workoutExerciseRow
	if err := ws.db.Select(&rows, exerciseJoinQuery, workoutID); err != nil {
		return nil, fmt.Errorf("loadExercises: %w", err)
	}
	exercises := make([]types.Exercise, len(rows))
	for i, r := range rows {
		exercises[i] = rowToExercise(r)
	}
	return exercises, nil
}

func (ws *WorkoutStore) insertExercises(tx *sqlx.Tx, workoutID string, inputs []types.WorkoutExerciseInput) error {
	for i, ex := range inputs {
		_, err := tx.Exec(`
			INSERT INTO workout_exercises
				(workout_id, exercise_id, position, sets, reps, weight_kg, duration_minutes, pace, hold_seconds, breath_count)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
			workoutID, ex.ExerciseID, i,
			ex.Sets, ex.Reps, ex.WeightKg,
			ex.DurationMinutes, ex.Pace,
			ex.HoldSeconds, ex.BreathCount,
		)
		if err != nil {
			return fmt.Errorf("insertExercises pos %d: %w", i, err)
		}
	}
	return nil
}

func (ws *WorkoutStore) GetWorkoutByID(id string) (*types.Workout, error) {
	var row workoutRow
	err := ws.db.Get(&row, `SELECT id, user_id, name, type FROM workouts WHERE id = $1`, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("GetWorkoutByID: %w", err)
	}

	exercises, err := ws.loadExercises(id)
	if err != nil {
		return nil, err
	}

	return &types.Workout{
		ID:        row.ID,
		UserID:    row.UserID,
		Name:      row.Name,
		Type:      types.WorkoutType(row.Type),
		Exercises: exercises,
	}, nil
}

func (ws *WorkoutStore) ListWorkoutsByUserID(userID string) ([]types.Workout, error) {
	var rows []workoutRow
	err := ws.db.Select(&rows,
		`SELECT id, user_id, name, type FROM workouts WHERE user_id = $1 ORDER BY id`,
		userID,
	)
	if err != nil {
		return nil, fmt.Errorf("ListWorkoutsByUserID: %w", err)
	}

	workouts := make([]types.Workout, 0, len(rows))
	for _, row := range rows {
		exercises, err := ws.loadExercises(row.ID)
		if err != nil {
			return nil, err
		}
		workouts = append(workouts, types.Workout{
			ID:        row.ID,
			UserID:    row.UserID,
			Name:      row.Name,
			Type:      types.WorkoutType(row.Type),
			Exercises: exercises,
		})
	}
	return workouts, nil
}

func (ws *WorkoutStore) InsertWorkout(input *types.WorkoutInput) error {
	tx, err := ws.db.Beginx()
	if err != nil {
		return fmt.Errorf("InsertWorkout begin: %w", err)
	}
	defer tx.Rollback()

	_, err = tx.Exec(
		`INSERT INTO workouts (id, user_id, name, type) VALUES ($1, $2, $3, $4)`,
		input.ID, input.UserID, input.Name, string(input.Type),
	)
	if err != nil {
		return fmt.Errorf("InsertWorkout: %w", err)
	}

	if err := ws.insertExercises(tx, input.ID, input.Exercises); err != nil {
		return err
	}

	return tx.Commit()
}

func (ws *WorkoutStore) UpdateWorkout(id string, input *types.WorkoutInput) error {
	tx, err := ws.db.Beginx()
	if err != nil {
		return fmt.Errorf("UpdateWorkout begin: %w", err)
	}
	defer tx.Rollback()

	res, err := tx.Exec(
		`UPDATE workouts SET name = $1, type = $2 WHERE id = $3`,
		input.Name, string(input.Type), id,
	)
	if err != nil {
		return fmt.Errorf("UpdateWorkout: %w", err)
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return ErrNotFound
	}

	if _, err = tx.Exec(`DELETE FROM workout_exercises WHERE workout_id = $1`, id); err != nil {
		return fmt.Errorf("UpdateWorkout delete exercises: %w", err)
	}

	if err := ws.insertExercises(tx, id, input.Exercises); err != nil {
		return err
	}

	return tx.Commit()
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
