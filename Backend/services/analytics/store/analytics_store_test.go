package store

import (
	"context"
	"database/sql"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/jmoiron/sqlx"
	"github.com/lib/pq"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newMockDB(t *testing.T) (*sqlx.DB, sqlmock.Sqlmock, func()) {
	t.Helper()
	raw, mock, err := sqlmock.New()
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	return db, mock, func() { _ = db.Close() }
}

func TestFindBatchByFingerprint_NotFound(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectQuery(`SELECT batch_id`).
		WithArgs("fp1").
		WillReturnError(sql.ErrNoRows)

	s := NewAnalyticsStore(db)
	id, found, err := s.FindBatchByFingerprint(context.Background(), "fp1")
	require.NoError(t, err)
	assert.False(t, found)
	assert.Equal(t, "", id)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestSaveBatch_EmptyEvents_InsertsBatchOnly(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectBegin()
	mock.ExpectExec(`INSERT INTO analytics_event_batches`).
		WithArgs("b1", "fp1", int64(7), 0, "received", "", "", "").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	s := NewAnalyticsStore(db)
	res, err := s.SaveBatch(context.Background(), "rid", "b1", "fp1", 7, []models.IngestedEvent{})
	require.NoError(t, err)
	assert.Equal(t, 0, res.InsertedEvents)
	assert.Equal(t, 0, res.DeduplicatedEvents)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestSaveBatch_UniqueViolation_ReturnsDeduplicatedWhenFingerprintExists(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	pqErr := &pq.Error{Code: "23505"}

	mock.ExpectBegin()
	mock.ExpectExec(`INSERT INTO analytics_event_batches`).
		WillReturnError(pqErr)

	mock.ExpectQuery(`SELECT batch_id`).
		WithArgs("fp1").
		WillReturnRows(sqlmock.NewRows([]string{"batch_id"}).AddRow("existing"))

	mock.ExpectRollback()

	s := NewAnalyticsStore(db)

	ev := models.IngestedEvent{
		Event: models.AnalyticsEventDTO{Platform: "iOS", AppVersion: "1"},
		IsValid: true,
	}
	res, err := s.SaveBatch(context.Background(), "rid", "b1", "fp1", 7, []models.IngestedEvent{ev, ev})
	require.NoError(t, err)
	assert.Equal(t, 0, res.InsertedEvents)
	assert.Equal(t, 2, res.DeduplicatedEvents)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestSaveBatch_OneInvalidEvent_GoesToInvalidTable(t *testing.T) {
	db, mock, cleanup := newMockDB(t)
	defer cleanup()

	mock.ExpectBegin()
	mock.ExpectExec(`INSERT INTO analytics_event_batches`).
		WillReturnResult(sqlmock.NewResult(0, 1))

	mock.ExpectQuery(`INSERT INTO analytics_events_raw`).
		WillReturnRows(sqlmock.NewRows([]string{"id"}).AddRow(int64(100)))

	mock.ExpectExec(`INSERT INTO analytics_invalid_events`).
		WillReturnResult(sqlmock.NewResult(0, 1))

	mock.ExpectCommit()

	s := NewAnalyticsStore(db)
	ev := models.IngestedEvent{
		Event: models.AnalyticsEventDTO{
			EventName: "x",
			Platform:  "iOS",
			AppVersion:"1",
			Timestamp: time.Now(),
			SessionID: "s",
			Properties: map[string]string{},
		},
		IsValid:      false,
		RejectReason: "nope",
	}

	res, err := s.SaveBatch(context.Background(), "rid", "b1", "fp1", 7, []models.IngestedEvent{ev})
	require.NoError(t, err)
	assert.Equal(t, 0, res.InsertedEvents)
	assert.Equal(t, 0, res.DeduplicatedEvents)
	require.NoError(t, mock.ExpectationsWereMet())
}

