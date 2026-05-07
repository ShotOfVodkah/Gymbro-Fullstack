package handlers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
	"github.com/jmoiron/sqlx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newMockSQLX(t *testing.T) (*sqlx.DB, sqlmock.Sqlmock, func()) {
	t.Helper()
	raw, mock, err := sqlmock.New(sqlmock.MonitorPingsOption(true))
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	return db, mock, func() { _ = db.Close() }
}

func TestHealthHandler_Health_OK(t *testing.T) {
	db, _, cleanup := newMockSQLX(t)
	defer cleanup()

	h := NewHealthHandler(store.NewHealthStore(db))
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/analytics/health", nil)
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	var payload map[string]any
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&payload))
	assert.Equal(t, "ok", payload["status"])
	assert.Equal(t, "analytics_service", payload["service"])
}

func TestHealthHandler_Ready_OK(t *testing.T) {
	db, mock, cleanup := newMockSQLX(t)
	defer cleanup()

	mock.ExpectPing().WillReturnError(nil)

	h := NewHealthHandler(store.NewHealthStore(db))
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/analytics/ready", nil)
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	require.NoError(t, mock.ExpectationsWereMet())
}

func TestHealthHandler_Ready_NotReady(t *testing.T) {
	db, mock, cleanup := newMockSQLX(t)
	defer cleanup()

	mock.ExpectPing().WillReturnError(assert.AnError)

	h := NewHealthHandler(store.NewHealthStore(db))
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/analytics/ready", nil)
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusServiceUnavailable, rr.Code)
	require.NoError(t, mock.ExpectationsWereMet())
}

