package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/jmoiron/sqlx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type stubEmailSender struct {
	err error
}

func (s stubEmailSender) SendVerificationEmail(to string, verificationURL string) error {
	return s.err
}

func newMockSQLX(t *testing.T) (*sqlx.DB, sqlmock.Sqlmock, func()) {
	t.Helper()
	raw, mock, err := sqlmock.New()
	require.NoError(t, err)
	db := sqlx.NewDb(raw, "sqlmock")
	return db, mock, func() { _ = db.Close() }
}

func doJSON(t *testing.T, h http.Handler, method, path string, body any) *httptest.ResponseRecorder {
	t.Helper()
	var buf bytes.Buffer
	if body != nil {
		require.NoError(t, json.NewEncoder(&buf).Encode(body))
	}
	req := httptest.NewRequest(method, path, &buf)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	return rr
}

func decodeMap(t *testing.T, rr *httptest.ResponseRecorder) map[string]any {
	t.Helper()
	var m map[string]any
	require.NoError(t, json.NewDecoder(rr.Body).Decode(&m))
	return m
}

func TestCreateUser_BadJSON(t *testing.T) {
	db, _, cleanup := newMockSQLX(t)
	defer cleanup()

	h := NewAuthHandler(db, []byte("secret"), stubEmailSender{}, "https://app/verify", "dev")
	req := httptest.NewRequest(http.MethodPost, "/auth/register", bytes.NewBufferString("{bad json"))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCreateUser_InvalidRole(t *testing.T) {
	db, _, cleanup := newMockSQLX(t)
	defer cleanup()

	h := NewAuthHandler(db, []byte("secret"), stubEmailSender{}, "https://app/verify", "dev")
	rr := doJSON(t, h, http.MethodPost, "/auth/register", map[string]any{
		"email":    "a@b.com",
		"password": "pass",
		"role":     "hacker",
	})
	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestCreateUser_OK_DevDoesNotFailIfEmailSendFails(t *testing.T) {
	db, mock, cleanup := newMockSQLX(t)
	defer cleanup()

	now := time.Now()
	mock.ExpectQuery(`INSERT INTO users`).
		WithArgs("a@b.com", sqlmock.AnyArg(), "athlete").
		WillReturnRows(sqlmock.NewRows([]string{
			"id", "email", "password_hash", "role", "email_verified", "inserted_at", "updated_at",
		}).AddRow(1, "a@b.com", "$argon2id$v=19$m=65536,t=1,p=1$abc$def", "athlete", false, now, now))

	mock.ExpectExec(`INSERT INTO email_verification_tokens`).
		WithArgs(1, sqlmock.AnyArg(), sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 1))

	h := NewAuthHandler(db, []byte("secret"), stubEmailSender{err: assert.AnError}, "https://app/verify-email", "dev")

	rr := doJSON(t, h, http.MethodPost, "/auth/register", map[string]any{
		"email":    "a@b.com",
		"password": "pass",
		"role":     "athlete",
	})

	assert.Equal(t, http.StatusOK, rr.Code)
	body := decodeMap(t, rr)
	assert.Equal(t, float64(1), body["id"])
	assert.Equal(t, "a@b.com", body["email"])
	assert.Equal(t, "athlete", body["role"])
	_, has := body["dev_verify_url"]
	assert.True(t, has, "dev response should include dev_verify_url")

	require.NoError(t, mock.ExpectationsWereMet())
}

func TestVerifyEmailLink_RedirectsToAppScheme(t *testing.T) {
	db, _, cleanup := newMockSQLX(t)
	defer cleanup()

	h := NewAuthHandler(db, []byte("secret"), stubEmailSender{}, "https://app/verify-email", "prod")
	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/auth/verify-email-link?token=t123", nil)
	h.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusFound, rr.Code)
	loc := rr.Header().Get("Location")
	assert.Equal(t, "gymbro://verify-email?token=t123", loc)
}

func TestAuthMiddleware_UnauthorizedWithoutBearerToken(t *testing.T) {
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/users", nil)
	AuthMiddleware([]byte("secret"))(next).ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

