package store

import (
	"context"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/jmoiron/sqlx"
	"github.com/alexandra-gritsaenko/gymbro-perks/types"
	"github.com/stretchr/testify/require"
)

func newMockDB(t *testing.T) (*sqlx.DB, sqlmock.Sqlmock, func()) {
	t.Helper()
	raw, mock, err := sqlmock.New()
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	return db, mock, func() { _ = db.Close() }
}

func TestPerksStore_EnsureUser_ExistingUserFastPath(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectExec(`INSERT INTO user_perks`).
		WithArgs(int64(7)).
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectExec(`INSERT INTO user_streaks`).
		WithArgs(int64(7), sqlmock.AnyArg(), sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectExec(`INSERT INTO user_achievements`).
		WithArgs(int64(7)).
		WillReturnResult(sqlmock.NewResult(0, 0))

	mock.ExpectBegin()
	mock.ExpectQuery(`SELECT last_freeze_grant_month`).
		WithArgs(int64(7)).
		WillReturnRows(sqlmock.NewRows([]string{"last_freeze_grant_month"}).AddRow(nil))

	mock.ExpectExec(`INSERT INTO streak_freezes`).
		WithArgs(int64(7)).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(`INSERT INTO streak_freezes`).
		WithArgs(int64(7)).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(`UPDATE user_perks`).
		WithArgs(int64(7), sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	s := NewPerksStore(db)
	require.NoError(t, s.EnsureUser(context.Background(), 7))
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestPerksStore_GrantMonthlyFreezesIfNeeded_SkipsIfAlreadyGrantedThisMonth(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	currentMonth := time.Now().Format("2006-01")

	mock.ExpectBegin()
	mock.ExpectQuery(`SELECT last_freeze_grant_month`).
		WithArgs(int64(7)).
		WillReturnRows(sqlmock.NewRows([]string{"last_freeze_grant_month"}).AddRow(currentMonth))
	mock.ExpectCommit()

	s := NewPerksStore(db)
	require.NoError(t, s.GrantMonthlyFreezesIfNeeded(context.Background(), 7))
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestPerksStore_SaveEvent_MarshalsAndInserts(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectExec(`INSERT INTO user_perks`).WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectExec(`INSERT INTO user_streaks`).WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectExec(`INSERT INTO user_achievements`).WillReturnResult(sqlmock.NewResult(0, 0))

	mock.ExpectBegin()
	mock.ExpectQuery(`SELECT last_freeze_grant_month`).WillReturnRows(sqlmock.NewRows([]string{"last_freeze_grant_month"}).AddRow(nil))
	mock.ExpectExec(`INSERT INTO streak_freezes`).WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(`INSERT INTO streak_freezes`).WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(`UPDATE user_perks`).WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	mock.ExpectExec(`INSERT INTO perk_events`).
		WithArgs(int64(7), "workout_completed", sqlmock.AnyArg(), sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 1))

	s := NewPerksStore(db)
	req := types.PerksEventRequest{
		Type:      "workout_completed",
		Metadata:  map[string]string{"weekday": "monday"},
		CreatedAt: time.Time{},
	}
	require.NoError(t, s.SaveEvent(context.Background(), 7, req))
	require.NoError(t, mock.ExpectationsWereMet())
}

