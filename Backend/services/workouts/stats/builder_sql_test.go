package stats

import (
	"database/sql"
	"encoding/json"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/jmoiron/sqlx"
	"github.com/stretchr/testify/require"
)

func expectNoRollupRow(mock sqlmock.Sqlmock, userID string) {
	mock.ExpectQuery(`SELECT user_id, total_sessions, sum_exercise_minutes, dow_counts, muscle_group_counts, workout_type_counts, updated_at\s+FROM user_workout_statistics WHERE user_id = \$1`).
		WithArgs(userID).
		WillReturnRows(sqlmock.NewRows([]string{"user_id", "total_sessions", "sum_exercise_minutes", "dow_counts", "muscle_group_counts", "workout_type_counts", "updated_at"}))
}


func TestBuildPayloadJSON_SqlMock(t *testing.T) {
	sqlDB, mock, err := sqlmock.New()
	require.NoError(t, err)
	defer sqlDB.Close()

	expectNoRollupRow(mock, "1")

	mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions WHERE user_id = \$1`).
		WithArgs("1").
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(2))

	mock.ExpectQuery(`SELECT COALESCE\(SUM\(wse\.duration_minutes\)`).
		WithArgs("1").
		WillReturnRows(sqlmock.NewRows([]string{"sum"}).AddRow(90))

	mock.ExpectQuery(`WITH per AS`).
		WithArgs("1").
		WillReturnRows(sqlmock.NewRows([]string{"avg"}).AddRow(45.0))

	mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions\s+WHERE user_id = \$1\s+AND completed_at >= \$2`).
		WithArgs("1", sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(1))

	mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions\s+WHERE user_id = \$1\s+AND completed_at >= \$2`).
		WithArgs("1", sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(2))

	mock.ExpectQuery(`SELECT COUNT\(DISTINCT to_char`).
		WithArgs("1", sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{"weeks_hit"}).AddRow(4))

	mock.ExpectQuery(`SELECT EXTRACT\(ISODOW`).
		WithArgs("1").
		WillReturnRows(sqlmock.NewRows([]string{"dow", "cnt"}).AddRow(3, 2))

	for range 4 {
		mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions\s+WHERE user_id = \$1\s+AND \(completed_at AT TIME ZONE 'UTC'\)::date >= \$2::date\s+AND \(completed_at AT TIME ZONE 'UTC'\)::date <= \$3::date`).
			WithArgs("1", sqlmock.AnyArg(), sqlmock.AnyArg()).
			WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(0))
	}

	for range 6 {
		mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions\s+WHERE user_id = \$1\s+AND completed_at >= \$2\s+AND completed_at <= \$3`).
			WithArgs("1", sqlmock.AnyArg(), sqlmock.AnyArg()).
			WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(0))
	}

	mock.ExpectQuery(`SELECT d\.muscle_group, COUNT\(\*\)::int AS cnt`).
		WithArgs("1").
		WillReturnRows(sqlmock.NewRows([]string{"muscle_group", "cnt"}).AddRow("Legs", 5))

	mock.ExpectQuery(`SELECT workout_type FROM workout_sessions`).
		WithArgs("1").
		WillReturnRows(sqlmock.NewRows([]string{"workout_type"}).AddRow("Strength"))

	db := sqlx.NewDb(sqlDB, "sqlmock")
	defer db.Close()

	b := NewBuilder(db)
	now := time.Date(2026, 4, 21, 12, 0, 0, 0, time.UTC)
	raw, err := b.BuildPayloadJSON("1", now)
	require.NoError(t, err)

	var p Payload
	require.NoError(t, json.Unmarshal(raw, &p))
	require.Equal(t, 2, p.Summary.TotalWorkouts)
	require.Equal(t, 1, p.Summary.TotalDurationHours)
	require.Equal(t, ConsistencyFromWeekHits(4, ConsistencyWeeksWindow), p.Summary.Consistency)
	require.Equal(t, "Wednesday", p.Summary.MostActiveDay)
	require.Equal(t, "Legs", p.Summary.FavoriteMuscleGroup)
	require.Equal(t, "Strength", p.FavoriteWorkoutType)
	require.Len(t, p.WeeklyActivity, 7)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestBuildPayloadJSON_NilDB(t *testing.T) {
	var b *Builder
	_, err := b.BuildPayloadJSON("1", time.Now())
	require.Error(t, err)
}

func TestBuildPayloadJSON_TopWorkoutTypeNoRows(t *testing.T) {
	sqlDB, mock, err := sqlmock.New()
	require.NoError(t, err)
	defer sqlDB.Close()

	expectNoRollupRow(mock, "9")

	mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions WHERE user_id = \$1`).
		WithArgs("9").
		WillReturnRows(sqlmock.NewRows([]string{"c"}).AddRow(0))
	mock.ExpectQuery(`SELECT COALESCE\(SUM\(wse\.duration_minutes\)`).
		WithArgs("9").
		WillReturnRows(sqlmock.NewRows([]string{"s"}).AddRow(0))
	mock.ExpectQuery(`WITH per AS`).
		WithArgs("9").
		WillReturnRows(sqlmock.NewRows([]string{"a"}).AddRow(0.0))
	mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions\s+WHERE user_id = \$1\s+AND completed_at >= \$2`).
		WithArgs("9", sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{"c"}).AddRow(0))
	mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions\s+WHERE user_id = \$1\s+AND completed_at >= \$2`).
		WithArgs("9", sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{"c"}).AddRow(0))
	mock.ExpectQuery(`SELECT COUNT\(DISTINCT to_char`).
		WithArgs("9", sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{"w"}).AddRow(0))
	mock.ExpectQuery(`SELECT EXTRACT\(ISODOW`).
		WithArgs("9").
		WillReturnRows(sqlmock.NewRows([]string{"dow", "cnt"}))
	for range 4 {
		mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions\s+WHERE user_id = \$1\s+AND \(completed_at AT TIME ZONE 'UTC'\)::date`).
			WithArgs("9", sqlmock.AnyArg(), sqlmock.AnyArg()).
			WillReturnRows(sqlmock.NewRows([]string{"c"}).AddRow(0))
	}
	for range 6 {
		mock.ExpectQuery(`SELECT COUNT\(\*\) FROM workout_sessions\s+WHERE user_id = \$1\s+AND completed_at >= \$2\s+AND completed_at <= \$3`).
			WithArgs("9", sqlmock.AnyArg(), sqlmock.AnyArg()).
			WillReturnRows(sqlmock.NewRows([]string{"c"}).AddRow(0))
	}
	mock.ExpectQuery(`SELECT d\.muscle_group, COUNT\(\*\)::int AS cnt`).
		WithArgs("9").
		WillReturnRows(sqlmock.NewRows([]string{"muscle_group", "cnt"}))
	mock.ExpectQuery(`SELECT workout_type FROM workout_sessions`).
		WithArgs("9").
		WillReturnError(sql.ErrNoRows)

	db := sqlx.NewDb(sqlDB, "sqlmock")
	defer db.Close()

	b := NewBuilder(db)
	raw, err := b.BuildPayloadJSON("9", time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC))
	require.NoError(t, err)
	var p Payload
	require.NoError(t, json.Unmarshal(raw, &p))
	require.Equal(t, "", p.FavoriteWorkoutType)
	require.NoError(t, mock.ExpectationsWereMet())
}
