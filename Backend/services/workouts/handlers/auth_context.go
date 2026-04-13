package handlers

import (
	"net/http"
	"strconv"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
)

type testUserIDKey struct{}

func AuthMiddleware(secret []byte) func(http.Handler) http.Handler {
	return authmw.Middleware(authmw.Config{
		Secret:       secret,
		Unauthorized: unauthorized,
	})
}

func userIDFromContext(r *http.Request) (string, bool) {
	if claims, ok := authmw.GetClaims(r.Context()); ok {
		return strconv.Itoa(claims.UserID), true
	}
	if v := r.Context().Value(testUserIDKey{}); v != nil {
		if s, ok := v.(string); ok && s != "" {
			return s, true
		}
	}
	return "", false
}
