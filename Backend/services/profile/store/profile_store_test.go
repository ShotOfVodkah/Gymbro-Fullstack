package store

import (
	"database/sql"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/jmoiron/sqlx"
	"github.com/stretchr/testify/require"
)

func TestEnsureProfile_InvalidUserID(t *testing.T) {
	sqlDB, _, err := sqlmock.New()
	require.NoError(t, err)
	defer sqlDB.Close()
	ps := NewProfileStore(sqlx.NewDb(sqlDB, "sqlmock"))

	require.Error(t, ps.EnsureProfile(0))
	require.Error(t, ps.EnsureProfile(-1))
}

func TestUpsertStatisticsPayload_EnsuresProfileBeforeStatistics(t *testing.T) {
	sqlDB, mock, err := sqlmock.New()
	require.NoError(t, err)
	defer sqlDB.Close()
	ps := NewProfileStore(sqlx.NewDb(sqlDB, "sqlmock"))

	mock.ExpectExec(`INSERT INTO profiles`).
		WithArgs(7, "user_7").
		WillReturnResult(sqlmock.NewResult(0, 1))

	payload := []byte(`{"summary":{}}`)
	mock.ExpectExec(`INSERT INTO profile_statistics`).
		WithArgs(7, payload).
		WillReturnResult(sqlmock.NewResult(0, 1))

	require.NoError(t, ps.UpsertStatisticsPayload(7, payload))
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestGetSettings_NoProfile_ReturnsNotFound(t *testing.T) {
	sqlDB, mock, err := sqlmock.New()
	require.NoError(t, err)
	defer sqlDB.Close()
	ps := NewProfileStore(sqlx.NewDb(sqlDB, "sqlmock"))

	mock.ExpectQuery(`SELECT user_id, push_notifications_enabled, workout_reminders, private_account`).
		WithArgs(9).
		WillReturnError(sql.ErrNoRows)

	mock.ExpectQuery(`SELECT user_id, name, username, status, subtitle, bio, avatar_system_name, badge, workouts_this_month`).
		WithArgs(9).
		WillReturnError(sql.ErrNoRows)

	_, gerr := ps.GetSettings(9)
	require.ErrorIs(t, gerr, ErrNotFound)
	require.NoError(t, mock.ExpectationsWereMet())
}
