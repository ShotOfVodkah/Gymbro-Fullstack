package store

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/jmoiron/sqlx"
	"github.com/lib/pq"
)

type SessionStore struct {
	db *sqlx.DB
}

func NewSessionStore(db *sqlx.DB) *SessionStore {
	return &SessionStore{db: db}
}

type SessionStorer interface {
	GetSessionByID(id string) (*types.WorkoutSession, error)
	InsertSession(input *types.SessionInput) error
	ListSessionsByUserID(userID string, from, to *time.Time) ([]types.WorkoutSession, error)
	GetSessionPreviewsByIDs(ids []string) ([]types.SessionPreviewItem, error)
	ListCalendarSessionsByUserAndMonth(userID string, month string) ([]types.CalendarWorkoutDayResponse, error)
	EnsureExercisesFromSessionDictionary(ids []string) error
}

var _ SessionStorer = (*SessionStore)(nil)

var ErrInvalidExerciseDictionary = errors.New("session exercise ids missing from dictionary or catalog")

type sessionRow struct {
	ID          string    `db:"id"`
	UserID      string    `db:"user_id"`
	WorkoutID   *string   `db:"workout_id"`
	WorkoutName string    `db:"workout_name"`
	WorkoutType string    `db:"workout_type"`
	CompletedAt time.Time `db:"completed_at"`
}

type sessionExerciseRow struct {
	ExerciseID      string   `db:"exercise_id"`
	ExerciseName    string   `db:"exercise_name"`
	ExerciseType    string   `db:"exercise_type"`
	MuscleGroup     string   `db:"muscle_group"`
	Sets            *int     `db:"sets"`
	Reps            *int     `db:"reps"`
	WeightKg        *float64 `db:"weight_kg"`
	DurationMinutes *int     `db:"duration_minutes"`
	Pace            *string  `db:"pace"`
	HoldSeconds     *int     `db:"hold_seconds"`
	BreathCount     *int     `db:"breath_count"`
}

type sessionPreviewRow struct {
	ID              string `db:"id"`
	Title           string `db:"title"`
	Category        string `db:"category"`
	DurationMinutes int    `db:"duration_minutes"`
	ExerciseCount   int    `db:"exercise_count"`
}

type sessionPreviewExerciseRow struct {
	SessionID       string   `db:"session_id"`
	ExerciseID      string   `db:"exercise_id"`
	ExerciseName    string   `db:"exercise_name"`
	ExerciseType    string   `db:"exercise_type"`
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

func rowToSession(row sessionRow, exercises []types.SessionExercise) types.WorkoutSession {
	return types.WorkoutSession{
		ID:          row.ID,
		UserID:      row.UserID,
		WorkoutID:   row.WorkoutID,
		WorkoutName: row.WorkoutName,
		WorkoutType: row.WorkoutType,
		CompletedAt: row.CompletedAt,
		Exercises:   exercises,
	}
}

func (ss *SessionStore) loadSessionExercises(sessionID string) ([]types.SessionExercise, error) {
	var rows []sessionExerciseRow
	err := ss.db.Select(&rows, `
		SELECT d.id AS exercise_id, d.name AS exercise_name, d.type AS exercise_type, d.muscle_group,
		       e.sets, e.reps, e.weight_kg, e.duration_minutes, e.pace, e.hold_seconds, e.breath_count
		FROM workout_session_exercise_entries e
		JOIN session_exercises d ON d.id = e.exercise_id
		WHERE e.session_id = $1
		ORDER BY e.position
	`, sessionID)
	if err != nil {
		return nil, fmt.Errorf("loadSessionExercises: %w", err)
	}

	exercises := make([]types.SessionExercise, len(rows))
	for i, r := range rows {
		exercises[i] = types.SessionExercise{
			ID:              r.ExerciseID,
			Name:            r.ExerciseName,
			Type:            r.ExerciseType,
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
	return exercises, nil
}

func (ss *SessionStore) GetSessionByID(id string) (*types.WorkoutSession, error) {
	var row sessionRow
	err := ss.db.Get(&row, `
		SELECT id, user_id, workout_id, workout_name, workout_type, completed_at
		FROM workout_sessions WHERE id = $1
	`, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("GetSessionByID: %w", err)
	}

	exercises, err := ss.loadSessionExercises(id)
	if err != nil {
		return nil, err
	}

	s := rowToSession(row, exercises)
	return &s, nil
}

func (ss *SessionStore) ListSessionsByUserID(userID string, from, to *time.Time) ([]types.WorkoutSession, error) {
	query := `SELECT id, user_id, workout_id, workout_name, workout_type, completed_at
		FROM workout_sessions WHERE user_id = $1`
	args := []any{userID}

	if from != nil {
		args = append(args, *from)
		query += fmt.Sprintf(" AND completed_at >= $%d", len(args))
	}
	if to != nil {
		args = append(args, *to)
		query += fmt.Sprintf(" AND completed_at <= $%d", len(args))
	}
	query += " ORDER BY completed_at DESC"

	var rows []sessionRow
	err := ss.db.Select(&rows, query, args...)
	if err != nil {
		return nil, fmt.Errorf("ListSessionsByUserID: %w", err)
	}

	sessions := make([]types.WorkoutSession, 0, len(rows))
	for _, row := range rows {
		exercises, err := ss.loadSessionExercises(row.ID)
		if err != nil {
			return nil, err
		}
		sessions = append(sessions, rowToSession(row, exercises))
	}
	return sessions, nil
}

func (ss *SessionStore) InsertSession(input *types.SessionInput) error {

	var workoutName, workoutType string
	err := ss.db.QueryRow(
		`SELECT name, type FROM workouts WHERE id = $1`, input.WorkoutID,
	).Scan(&workoutName, &workoutType)
	if err != nil {
		return fmt.Errorf("InsertSession resolve workout: %w", err)
	}

	completedAt := time.Now()
	if input.CompletedAt != nil {
		completedAt = *input.CompletedAt
	}

	tx, err := ss.db.Beginx()
	if err != nil {
		return fmt.Errorf("InsertSession begin: %w", err)
	}
	defer tx.Rollback()

	_, err = tx.Exec(`
		INSERT INTO workout_sessions (id, user_id, workout_id, workout_name, workout_type, completed_at)
		VALUES ($1, $2, $3, $4, $5, $6)`,
		input.ID, input.UserID, input.WorkoutID, workoutName, workoutType, completedAt,
	)
	if err != nil {
		return fmt.Errorf("InsertSession insert session: %w", err)
	}

	for i, ex := range input.Exercises {
		var exName, exType, muscleGroup string
		err := tx.QueryRow(
			`SELECT name, type, muscle_group FROM exercises WHERE id = $1`, ex.ExerciseID,
		).Scan(&exName, &exType, &muscleGroup)
		if errors.Is(err, sql.ErrNoRows) {
			err = tx.QueryRow(
				`SELECT name, type, muscle_group FROM session_exercises WHERE id = $1`, ex.ExerciseID,
			).Scan(&exName, &exType, &muscleGroup)
		}
		if err != nil {
			return fmt.Errorf("InsertSession resolve exercise %s: %w", ex.ExerciseID, err)
		}

		_, err = tx.Exec(`
			INSERT INTO session_exercises (id, name, type, muscle_group)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (id) DO NOTHING`,
			ex.ExerciseID, exName, exType, muscleGroup,
		)
		if err != nil {
			return fmt.Errorf("InsertSession upsert session exercise %s: %w", ex.ExerciseID, err)
		}

		_, err = tx.Exec(`
			INSERT INTO workout_session_exercise_entries
				(session_id, exercise_id, position,
				 sets, reps, weight_kg, duration_minutes, pace, hold_seconds, breath_count)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
			input.ID, ex.ExerciseID, i,
			ex.Sets, ex.Reps, ex.WeightKg,
			ex.DurationMinutes, ex.Pace,
			ex.HoldSeconds, ex.BreathCount,
		)
		if err != nil {
			return fmt.Errorf("InsertSession insert exercise pos %d: %w", i, err)
		}
	}

	return tx.Commit()
}

func (ss *SessionStore) GetSessionPreviewsByIDs(ids []string) ([]types.SessionPreviewItem, error) {
	if len(ids) == 0 {
		return []types.SessionPreviewItem{}, nil
	}

	query, args, err := sqlx.In(`
		SELECT
			ws.id,
			ws.workout_name AS title,
			ws.workout_type AS category,
			COALESCE(SUM(COALESCE(se.duration_minutes, 0)), 0) AS duration_minutes,
			COUNT(se.id) AS exercise_count
		FROM workout_sessions ws
		LEFT JOIN workout_session_exercise_entries se ON se.session_id = ws.id
		WHERE ws.id IN (?)
		GROUP BY ws.id, ws.workout_name, ws.workout_type
	`, ids)
	if err != nil {
		return nil, fmt.Errorf("GetSessionPreviewsByIDs build main query: %w", err)
	}
	query = ss.db.Rebind(query)

	var previewRows []sessionPreviewRow
	if err := ss.db.Select(&previewRows, query, args...); err != nil {
		return nil, fmt.Errorf("GetSessionPreviewsByIDs select previews: %w", err)
	}

	exQuery, exArgs, err := sqlx.In(`
		SELECT
			e.session_id,
			d.id AS exercise_id,
			d.name AS exercise_name,
			d.type AS exercise_type,
			d.muscle_group,
			e.position,
			e.sets,
			e.reps,
			e.weight_kg,
			e.duration_minutes,
			e.pace,
			e.hold_seconds,
			e.breath_count
		FROM workout_session_exercise_entries e
		JOIN session_exercises d ON d.id = e.exercise_id
		WHERE e.session_id IN (?)
		ORDER BY e.session_id, e.position
	`, ids)
	if err != nil {
		return nil, fmt.Errorf("GetSessionPreviewsByIDs build exercises query: %w", err)
	}
	exQuery = ss.db.Rebind(exQuery)

	var exRows []sessionPreviewExerciseRow
	if err := ss.db.Select(&exRows, exQuery, exArgs...); err != nil {
		return nil, fmt.Errorf("GetSessionPreviewsByIDs select exercises: %w", err)
	}

	exMap := make(map[string][]types.SessionPreviewExercise)
	for _, row := range exRows {
		current := exMap[row.SessionID]
		if len(current) >= 2 {
			continue
		}

		exMap[row.SessionID] = append(current, types.SessionPreviewExercise{
			ID:              row.ExerciseID,
			Name:            row.ExerciseName,
			Type:            row.ExerciseType,
			MuscleGroup:     row.MuscleGroup,
			Sets:            row.Sets,
			Reps:            row.Reps,
			WeightKg:        row.WeightKg,
			DurationMinutes: row.DurationMinutes,
			Pace:            row.Pace,
			HoldSeconds:     row.HoldSeconds,
			BreathCount:     row.BreathCount,
		})
	}

	items := make([]types.SessionPreviewItem, 0, len(previewRows))
	for _, row := range previewRows {
		items = append(items, types.SessionPreviewItem{
			ID:               row.ID,
			Title:            row.Title,
			Category:         row.Category,
			DurationMinutes:  row.DurationMinutes,
			ExerciseCount:    row.ExerciseCount,
			ExercisesPreview: exMap[row.ID],
		})
	}

	return items, nil
}

func (ss *SessionStore) ListCalendarSessionsByUserAndMonth(userID string, month string) ([]types.CalendarWorkoutDayResponse, error) {
	query := `
		SELECT
			TO_CHAR(completed_at AT TIME ZONE 'UTC', 'YYYY-MM-DD') AS date,
			id AS workout_id
		FROM workout_sessions
		WHERE user_id = $1
		  AND TO_CHAR(completed_at AT TIME ZONE 'UTC', 'YYYY-MM') = $2
		ORDER BY completed_at
	`

	var items []types.CalendarWorkoutDayResponse
	if err := ss.db.Select(&items, query, userID, month); err != nil {
		return nil, fmt.Errorf("ListCalendarSessionsByUserAndMonth: %w", err)
	}

	return items, nil
}

func (ss *SessionStore) EnsureExercisesFromSessionDictionary(ids []string) error {
	seen := make(map[string]struct{})
	var uniq []string
	for _, id := range ids {
		if id == "" {
			continue
		}
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}
		uniq = append(uniq, id)
	}
	if len(uniq) == 0 {
		return nil
	}

	_, err := ss.db.Exec(`
		INSERT INTO exercises (id, name, type, muscle_group)
		SELECT se.id, se.name, se.type, se.muscle_group
		FROM session_exercises se
		WHERE se.id = ANY($1)
		  AND NOT EXISTS (SELECT 1 FROM exercises e WHERE e.id = se.id)
	`, pq.Array(uniq))
	if err != nil {
		return fmt.Errorf("EnsureExercisesFromSessionDictionary insert: %w", err)
	}

	var count int
	err = ss.db.Get(&count, `SELECT COUNT(*) FROM exercises WHERE id = ANY($1)`, pq.Array(uniq))
	if err != nil {
		return fmt.Errorf("EnsureExercisesFromSessionDictionary count: %w", err)
	}
	if count != len(uniq) {
		return ErrInvalidExerciseDictionary
	}
	return nil
}