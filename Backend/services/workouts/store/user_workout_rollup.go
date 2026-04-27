package store

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

type UserWorkoutStatsRollup struct {
	UserID              string
	TotalSessions       int
	SumExerciseMinutes  int64
	DowCounts           [7]int
	MuscleGroupCounts   map[string]int
	WorkoutTypeCounts   map[string]int
	UpdatedAt           time.Time
}

type rollupRow struct {
	UserID             string    `db:"user_id"`
	TotalSessions      int       `db:"total_sessions"`
	SumExerciseMinutes int64     `db:"sum_exercise_minutes"`
	Dow                []byte    `db:"dow_counts"`
	MG                 []byte    `db:"muscle_group_counts"`
	WT                 []byte    `db:"workout_type_counts"`
	Updated            time.Time `db:"updated_at"`
}

func parseDowFromJSON(raw []byte) [7]int {
	var a []int
	if err := json.Unmarshal(raw, &a); err != nil || len(a) < 7 {
		return [7]int{}
	}
	var o [7]int
	for i := 0; i < 7; i++ {
		o[i] = a[i]
	}
	return o
}

func dowToJSON(d [7]int) []byte {
	b, _ := json.Marshal([]int{d[0], d[1], d[2], d[3], d[4], d[5], d[6]})
	return b
}

func GetUserWorkoutStats(ctx context.Context, db sqlx.ExtContext, userID string) (*UserWorkoutStatsRollup, bool, error) {
	var row rollupRow
	err := sqlx.GetContext(ctx, db, &row, `
		SELECT user_id, total_sessions, sum_exercise_minutes, dow_counts, muscle_group_counts, workout_type_counts, updated_at
		FROM user_workout_statistics WHERE user_id = $1
	`, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, false, nil
	}
	if err != nil {
		return nil, false, fmt.Errorf("GetUserWorkoutStats: %w", err)
	}
	return &UserWorkoutStatsRollup{
		UserID:             row.UserID,
		TotalSessions:      row.TotalSessions,
		SumExerciseMinutes: row.SumExerciseMinutes,
		DowCounts:          parseDowFromJSON(row.Dow),
		MuscleGroupCounts:  parseStringIntMapJSON(row.MG),
		WorkoutTypeCounts:  parseStringIntMapJSON(row.WT),
		UpdatedAt:          row.Updated,
	}, true, nil
}

func parseStringIntMapJSON(raw []byte) map[string]int {
	if len(raw) == 0 || string(raw) == "null" {
		return map[string]int{}
	}
	var m map[string]int
	if err := json.Unmarshal(raw, &m); err != nil {
		return map[string]int{}
	}
	if m == nil {
		return map[string]int{}
	}
	return m
}

func RebuildUserWorkoutStatsFromDB(ctx context.Context, tx *sqlx.Tx, userID string) error {
	var n int
	if err := tx.GetContext(ctx, &n, `SELECT COUNT(*) FROM workout_sessions WHERE user_id = $1`, userID); err != nil {
		return fmt.Errorf("rollup count sessions: %w", err)
	}
	if n == 0 {
		return nil
	}

	var sumEx int64
	if err := tx.GetContext(ctx, &sumEx, `
		SELECT COALESCE(SUM(wse.duration_minutes), 0)
		FROM workout_session_exercise_entries wse
		INNER JOIN workout_sessions ws ON ws.id = wse.session_id
		WHERE ws.user_id = $1 AND wse.duration_minutes IS NOT NULL
	`, userID); err != nil {
		return fmt.Errorf("rollup sum duration: %w", err)
	}

	var dowRows []struct {
		Dow int `db:"dow"`
		Cnt int `db:"cnt"`
	}
	if err := tx.SelectContext(ctx, &dowRows, `
		SELECT EXTRACT(ISODOW FROM completed_at AT TIME ZONE 'UTC')::int AS dow, COUNT(*)::int AS cnt
		FROM workout_sessions
		WHERE user_id = $1
		GROUP BY 1
	`, userID); err != nil {
		return fmt.Errorf("rollup dow: %w", err)
	}
	var dow [7]int
	for _, r := range dowRows {
		if r.Dow >= 1 && r.Dow <= 7 {
			dow[r.Dow-1] = r.Cnt
		}
	}

	var mgRows []struct {
		Muscle string `db:"muscle_group"`
		Cnt    int    `db:"cnt"`
	}
	if err := tx.SelectContext(ctx, &mgRows, `
		SELECT d.muscle_group, COUNT(*)::int AS cnt
		FROM workout_session_exercise_entries wse
		INNER JOIN workout_sessions ws ON ws.id = wse.session_id
		INNER JOIN session_exercises d ON d.id = wse.exercise_id
		WHERE ws.user_id = $1 AND d.muscle_group <> ''
		GROUP BY d.muscle_group
	`, userID); err != nil {
		return fmt.Errorf("rollup muscle: %w", err)
	}
	mg := make(map[string]int)
	for _, r := range mgRows {
		mg[r.Muscle] = r.Cnt
	}

	var wtRows []struct {
		Typ string `db:"workout_type"`
		Cnt int    `db:"cnt"`
	}
	if err := tx.SelectContext(ctx, &wtRows, `
		SELECT workout_type, COUNT(*)::int AS cnt
		FROM workout_sessions
		WHERE user_id = $1
		GROUP BY workout_type
	`, userID); err != nil {
		return fmt.Errorf("rollup type: %w", err)
	}
	wt := make(map[string]int)
	for _, r := range wtRows {
		wt[r.Typ] = r.Cnt
	}

	mgJ, _ := json.Marshal(mg)
	wtJ, _ := json.Marshal(wt)
	_, err := tx.ExecContext(ctx, `
		INSERT INTO user_workout_statistics (user_id, total_sessions, sum_exercise_minutes, dow_counts, muscle_group_counts, workout_type_counts, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, now())
		ON CONFLICT (user_id) DO UPDATE SET
			total_sessions = EXCLUDED.total_sessions,
			sum_exercise_minutes = EXCLUDED.sum_exercise_minutes,
			dow_counts = EXCLUDED.dow_counts,
			muscle_group_counts = EXCLUDED.muscle_group_counts,
			workout_type_counts = EXCLUDED.workout_type_counts,
			updated_at = now()
	`, userID, n, sumEx, dowToJSON(dow), mgJ, wtJ)
	if err != nil {
		return fmt.Errorf("rollup upsert rebuild: %w", err)
	}
	return nil
}

func ApplyNewSessionToRollup(ctx context.Context, tx *sqlx.Tx, userID, workoutType string, completedAt time.Time, exerciseMuscles []string, sumExerciseMinutes int) error {
	ru, has, err := GetUserWorkoutStats(ctx, tx, userID)
	if err != nil {
		return err
	}
	if !has {
		if err := RebuildUserWorkoutStatsFromDB(ctx, tx, userID); err != nil {
			return err
		}
		return nil
	}

	ru.TotalSessions++
	ru.SumExerciseMinutes += int64(sumExerciseMinutes)
	d := int(completedAt.UTC().Weekday())
	isoD := (d+6)%7 + 1
	if isoD < 1 || isoD > 7 {
		return fmt.Errorf("iso dow out of range: %d", isoD)
	}
	ru.DowCounts[isoD-1]++

	for _, m := range exerciseMuscles {
		if m == "" {
			continue
		}
		ru.MuscleGroupCounts[m]++
	}
	ru.WorkoutTypeCounts[workoutType]++

	mgJ, _ := json.Marshal(ru.MuscleGroupCounts)
	wtJ, _ := json.Marshal(ru.WorkoutTypeCounts)
	_, err = tx.ExecContext(ctx, `
		UPDATE user_workout_statistics SET
			total_sessions = $2,
			sum_exercise_minutes = $3,
			dow_counts = $4,
			muscle_group_counts = $5,
			workout_type_counts = $6,
			updated_at = now()
		WHERE user_id = $1
	`, userID, ru.TotalSessions, ru.SumExerciseMinutes, dowToJSON(ru.DowCounts), mgJ, wtJ)
	if err != nil {
		return fmt.Errorf("ApplyNewSessionToRollup update: %w", err)
	}
	return nil
}
