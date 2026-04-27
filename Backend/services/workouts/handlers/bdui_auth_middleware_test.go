package handlers

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/dgrijalva/jwt-go"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func jwtForUser(t *testing.T, secret []byte, userID int) string {
	t.Helper()
	claims := &authmw.Claims{
		UserID: userID,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: 9999999999,
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	s, err := token.SignedString(secret)
	require.NoError(t, err)
	return s
}

func TestWorkoutsAuthMiddleware_userJWT_unchanged(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(secret, "bdui-secret")
	called := false
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		uid, ok := userIDFromContext(r)
		assert.True(t, ok)
		assert.Equal(t, "42", uid)
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set("Authorization", "Bearer "+jwtForUser(t, secret, 42))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	assert.True(t, called)
	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestWorkoutsAuthMiddleware_bduiPath(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(secret, "bdui-secret")
	called := false
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		uid, ok := userIDFromContext(r)
		assert.True(t, ok)
		assert.Equal(t, "7", uid)
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set(HeaderBduiSecret, "bdui-secret")
	req.Header.Set(HeaderBduiUserID, "7")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	assert.True(t, called)
	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestWorkoutsAuthMiddleware_bduiPath_wrongSecret(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(secret, "bdui-secret")
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set(HeaderBduiSecret, "wrong")
	req.Header.Set(HeaderBduiUserID, "7")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestWorkoutsAuthMiddleware_bduiPath_userIdWithoutM2M(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(secret, "bdui-secret")
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set(HeaderBduiUserID, "7")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestWorkoutsAuthMiddleware_m2mDisabled_noBearer(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(secret, "")
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestWorkoutsAuthMiddleware_userJWT_ignoresXUserId(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(secret, "bdui-secret")
	called := false
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		uid, ok := userIDFromContext(r)
		assert.True(t, ok)
		assert.Equal(t, "1", uid)
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set("Authorization", "Bearer "+jwtForUser(t, secret, 1))
	req.Header.Set(HeaderBduiUserID, "999")
	req.Header.Set(HeaderBduiSecret, "bdui-secret")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	assert.True(t, called)
	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestWorkoutsAuthMiddleware_invalidBearer_noFallbackToBdui(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(secret, "bdui-secret")
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set("Authorization", "Bearer not-a-jwt")
	req.Header.Set(HeaderBduiSecret, "bdui-secret")
	req.Header.Set(HeaderBduiUserID, "7")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestUserIDFromContext_bduiKey(t *testing.T) {
	uid, ok := userIDFromContext(httptest.NewRequest(http.MethodGet, "/", nil).WithContext(
		context.WithValue(context.Background(), bduiUserIDKey{}, "99"),
	))
	assert.True(t, ok)
	assert.Equal(t, "99", uid)
}
