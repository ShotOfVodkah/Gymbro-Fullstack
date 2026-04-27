package handlers

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

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

func m2mToken(t *testing.T, key *rsa.PrivateKey, userID string) string {
	t.Helper()
	claims := &BduiM2MClaims{
		UserID: userID,
		StandardClaims: jwt.StandardClaims{
			Issuer:    DefaultBduiM2MISS,
			Audience:  DefaultBduiM2MAud,
			Subject:   DefaultBduiM2MSub,
			ExpiresAt: time.Now().Add(5 * time.Minute).Unix(),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	s, err := token.SignedString(key)
	require.NoError(t, err)
	return s
}

func testKey(t *testing.T) *rsa.PrivateKey {
	t.Helper()
	k, err := rsa.GenerateKey(rand.Reader, 2048)
	require.NoError(t, err)
	return k
}

func TestWorkoutsAuthMiddleware_userJWT_HS256(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(WorkoutsAuthConfig{UserJWTSecret: secret, BduiM2MPublic: nil})
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

func TestWorkoutsAuthMiddleware_RS256_bduiM2M(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	key := testKey(t)
	mw := WorkoutsAuthMiddleware(WorkoutsAuthConfig{UserJWTSecret: secret, BduiM2MPublic: &key.PublicKey})
	called := false
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		uid, ok := userIDFromContext(r)
		assert.True(t, ok)
		assert.Equal(t, "7", uid)
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set("Authorization", "Bearer "+m2mToken(t, key, "7"))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)

	assert.True(t, called)
	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestWorkoutsAuthMiddleware_RS256_nilPublicRejects(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	key := testKey(t)
	mw := WorkoutsAuthMiddleware(WorkoutsAuthConfig{UserJWTSecret: secret, BduiM2MPublic: nil})
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set("Authorization", "Bearer "+m2mToken(t, key, "7"))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestWorkoutsAuthMiddleware_RS256_wrongKey(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	signKey := testKey(t)
	otherKey := testKey(t)
	mw := WorkoutsAuthMiddleware(WorkoutsAuthConfig{UserJWTSecret: secret, BduiM2MPublic: &otherKey.PublicKey})
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set("Authorization", "Bearer "+m2mToken(t, signKey, "7"))
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestWorkoutsAuthMiddleware_noBearer_401(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(WorkoutsAuthConfig{UserJWTSecret: secret})
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestWorkoutsAuthMiddleware_invalidBearer_401(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	mw := WorkoutsAuthMiddleware(WorkoutsAuthConfig{UserJWTSecret: secret, BduiM2MPublic: nil})
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set("Authorization", "Bearer not-a-jwt")
	rr := httptest.NewRecorder()
	h.ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

func TestWorkoutsAuthMiddleware_m2mWrongIss(t *testing.T) {
	secret := []byte("test-secret-32-bytes-long-okok")
	key := testKey(t)
	mw := WorkoutsAuthMiddleware(WorkoutsAuthConfig{UserJWTSecret: secret, BduiM2MPublic: &key.PublicKey})
	h := mw(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("next must not be called")
	}))

	claims := &BduiM2MClaims{
		UserID: "1",
		StandardClaims: jwt.StandardClaims{
			Issuer:    "wrong-iss",
			Audience:  DefaultBduiM2MAud,
			Subject:   DefaultBduiM2MSub,
			ExpiresAt: time.Now().Add(5 * time.Minute).Unix(),
		},
	}
	tok := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	s, err := tok.SignedString(key)
	require.NoError(t, err)

	req := httptest.NewRequest(http.MethodGet, "/workouts/w1", nil)
	req.Header.Set("Authorization", "Bearer "+s)
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
