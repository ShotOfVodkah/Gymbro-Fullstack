package store

import (
	"database/sql"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/alexandra-gritsaenko/gymbro-challenges/models"
	"github.com/jmoiron/sqlx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newMockDB(t *testing.T) (*sqlx.DB, sqlmock.Sqlmock, func()) {
	t.Helper()
	raw, mock, err := sqlmock.New()
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	cleanup := func() { _ = db.Close() }
	return db, mock, cleanup
}

func TestGetChallenge_NotFound(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`SELECT \* FROM challenges WHERE id = \$1`).
		WithArgs("c1").
		WillReturnError(sql.ErrNoRows)

	s := NewPostgresChallengeStore(db)
	got, err := s.GetChallenge("c1")
	assert.ErrorIs(t, err, ErrNotFound)
	assert.Nil(t, got)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestIsChatAlreadyJoined_OK(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`SELECT EXISTS\(`).
		WithArgs("c1", "chat1").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	s := NewPostgresChallengeStore(db)
	ok, err := s.IsChatAlreadyJoined("c1", "chat1")
	require.NoError(t, err)
	assert.True(t, ok)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestListChallenges_OK(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	rows := sqlmock.NewRows([]string{"id", "title", "description", "type", "status"}).
		AddRow("c1", "T1", "D", "team_workouts_count", "active")
	mock.ExpectQuery(`SELECT \*`).
		WillReturnRows(rows)

	s := NewPostgresChallengeStore(db)
	items, err := s.ListChallenges()
	require.NoError(t, err)
	require.Len(t, items, 1)
	assert.Equal(t, "c1", items[0].ID)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestCreateTeam_OK(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectExec(`INSERT INTO challenge_teams`).
		WillReturnResult(sqlmock.NewResult(0, 1))

	s := NewPostgresChallengeStore(db)
	err := s.CreateTeam(models.ChallengeTeam{ID: "t1", ChallengeID: "c1", ChatID: "chat1"})
	require.NoError(t, err)
	require.NoError(t, mock.ExpectationsWereMet())
}

