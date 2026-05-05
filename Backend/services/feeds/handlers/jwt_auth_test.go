package handlers

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/dgrijalva/jwt-go"
	"github.com/stretchr/testify/assert"
)

func signToken(secret []byte, userID int) string {
	t := jwt.NewWithClaims(jwt.SigningMethodHS256, authmw.Claims{
		UserID: userID,
		Email:  "u@example.com",
		Role:   "athlete",
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(time.Hour).Unix(),
			Issuer:    "test",
		},
	})
	s, _ := t.SignedString(secret)
	return s
}

func TestAuthMiddleware_UnauthorizedWithoutHeader(t *testing.T) {
	secret := []byte("secret")
	nextCalled := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		nextCalled = true
		w.WriteHeader(http.StatusOK)
	})

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/feed", nil)
	AuthMiddleware(secret)(next).ServeHTTP(rr, req)
	assert.Equal(t, http.StatusUnauthorized, rr.Code)
	assert.False(t, nextCalled)
}

func TestAuthMiddleware_AllowsValidToken(t *testing.T) {
	secret := []byte("secret")
	nextCalled := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		nextCalled = true
		w.WriteHeader(http.StatusOK)
	})

	rr := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/feed", nil)
	req.Header.Set("Authorization", "Bearer "+signToken(secret, 123))
	AuthMiddleware(secret)(next).ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.True(t, nextCalled)
}

