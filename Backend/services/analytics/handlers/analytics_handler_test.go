package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	authmw "github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
	"github.com/DATA-DOG/go-sqlmock"
	"github.com/jmoiron/sqlx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAnalyticsHandler_UnauthorizedWithoutClaims(t *testing.T) {
	raw, _, err := sqlmock.New()
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	defer db.Close()

	h := NewAnalyticsHandler(store.NewAnalyticsStore(db))
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/analytics/events/batch", bytes.NewBufferString("[]"))
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestAnalyticsHandler_BadJSON(t *testing.T) {
	raw, _, err := sqlmock.New()
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	defer db.Close()

	h := NewAnalyticsHandler(store.NewAnalyticsStore(db))
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/analytics/events/batch", bytes.NewBufferString("{bad json"))
	req = req.WithContext(authmw.ContextWithClaims(context.Background(), &authmw.Claims{UserID: 1}))
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestAnalyticsHandler_EmptyEventsReturnsBadRequestWithoutDB(t *testing.T) {
	raw, _, err := sqlmock.New()
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	defer db.Close()

	h := NewAnalyticsHandler(store.NewAnalyticsStore(db))

	var buf bytes.Buffer
	require.NoError(t, json.NewEncoder(&buf).Encode([]any{}))

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/analytics/events/batch", &buf)
	req = req.WithContext(authmw.ContextWithClaims(context.Background(), &authmw.Claims{UserID: 1}))
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

