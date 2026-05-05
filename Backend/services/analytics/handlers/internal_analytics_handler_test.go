package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"database/sql"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	authmw "github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
	"github.com/DATA-DOG/go-sqlmock"
	"github.com/jmoiron/sqlx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestInternalAnalyticsHandler_ForbiddenWithoutSecret(t *testing.T) {
	db, _, err := sqlmock.New()
	require.NoError(t, err)
	sqlxDB := sqlx.NewDb(db, "sqlmock")
	t.Cleanup(func() { _ = sqlxDB.Close() })

	t.Setenv("INTERNAL_SERVICE_SECRET", "secret")
	h := NewInternalAnalyticsHandler(store.NewAnalyticsStore(sqlxDB))

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/internal/analytics/events", bytes.NewBufferString(`{}`))
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusForbidden, rr.Code)
}

func TestInternalAnalyticsHandler_BadJSON(t *testing.T) {
	raw, _, err := sqlmock.New()
	require.NoError(t, err)
	sqlxDB := sqlx.NewDb(raw, "sqlmock")
	t.Cleanup(func() { _ = sqlxDB.Close() })

	t.Setenv("INTERNAL_SERVICE_SECRET", "secret")
	h := NewInternalAnalyticsHandler(store.NewAnalyticsStore(sqlxDB))

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/internal/analytics/events", bytes.NewBufferString("{bad json"))
	req.Header.Set("X-Internal-Secret", "secret")
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestInternalAnalyticsHandler_EventNameRequired(t *testing.T) {
	raw, _, err := sqlmock.New()
	require.NoError(t, err)
	sqlxDB := sqlx.NewDb(raw, "sqlmock")
	t.Cleanup(func() { _ = sqlxDB.Close() })

	t.Setenv("INTERNAL_SERVICE_SECRET", "secret")
	h := NewInternalAnalyticsHandler(store.NewAnalyticsStore(sqlxDB))

	body := models.InternalAnalyticsEventRequest{EventName: "", Properties: map[string]string{}}
	var buf bytes.Buffer
	require.NoError(t, json.NewEncoder(&buf).Encode(body))

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/internal/analytics/events", &buf)
	req.Header.Set("X-Internal-Secret", "secret")
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestInternalAnalyticsHandler_OK_UsesIngestBatch(t *testing.T) {
	raw, mock, err := sqlmock.New()
	require.NoError(t, err)
	sqlxDB := sqlx.NewDb(raw, "sqlmock")
	t.Cleanup(func() { _ = sqlxDB.Close() })

	t.Setenv("INTERNAL_SERVICE_SECRET", "secret")
	h := NewInternalAnalyticsHandler(store.NewAnalyticsStore(sqlxDB))

	mock.ExpectQuery(`SELECT batch_id`).
		WillReturnError(sql.ErrNoRows)

	mock.ExpectBegin()
	mock.ExpectExec(`INSERT INTO analytics_event_batches`).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectQuery(`INSERT INTO analytics_events_raw`).
		WillReturnRows(sqlmock.NewRows([]string{"id"}).AddRow(int64(1)))

	mock.ExpectExec(`INSERT INTO analytics_invalid_events`).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	body := models.InternalAnalyticsEventRequest{
		EventName:  "unknown_event_name",
		Properties: map[string]string{"k": "v"},
		Timestamp:  time.Now().Format(time.RFC3339),
		Platform:   "backend",
	}
	var buf bytes.Buffer
	require.NoError(t, json.NewEncoder(&buf).Encode(body))

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/internal/analytics/events", &buf)
	req.Header.Set("X-Internal-Secret", "secret")
	req = req.WithContext(authmw.ContextWithClaims(context.Background(), &authmw.Claims{UserID: 1}))

	h.ServeHTTP(rr, req)
	
	assert.NotEqual(t, http.StatusInternalServerError, rr.Code)
	require.NoError(t, mock.ExpectationsWereMet())

	_ = os.Getenv("INTERNAL_SERVICE_SECRET")
}

