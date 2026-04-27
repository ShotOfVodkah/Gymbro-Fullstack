package handlers

import (
	"context"
	"net/http"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
)

const (
	HeaderBduiSecret = "X-BDUI-Secret"
	HeaderBduiUserID = "X-User-Id"
)

type testUserIDKey struct{}
type bduiUserIDKey struct{}

func AuthMiddleware(secret []byte) func(http.Handler) http.Handler {
	return authmw.Middleware(authmw.Config{
		Secret:       secret,
		Unauthorized: unauthorized,
	})
}

func WorkoutsAuthMiddleware(jwtSecret []byte, bduiSecret string) func(http.Handler) http.Handler {
	jwtMW := authmw.Middleware(authmw.Config{
		Secret:       jwtSecret,
		Unauthorized: unauthorized,
	})
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			auth := r.Header.Get("Authorization")
			tokenString := ""
			if auth != "" && strings.HasPrefix(auth, "Bearer ") {
				tokenString = strings.TrimSpace(strings.TrimPrefix(auth, "Bearer "))
			}
			if tokenString != "" {
				jwtMW(next).ServeHTTP(w, r)
				return
			}
			if strings.TrimSpace(bduiSecret) == "" {
				unauthorized(w, r)
				return
			}
			if r.Header.Get(HeaderBduiSecret) != bduiSecret {
				unauthorized(w, r)
				return
			}
			uid := strings.TrimSpace(r.Header.Get(HeaderBduiUserID))
			if uid == "" {
				unauthorized(w, r)
				return
			}
			ctx := context.WithValue(r.Context(), bduiUserIDKey{}, uid)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func userIDFromContext(r *http.Request) (string, bool) {
	if claims, ok := authmw.GetClaims(r.Context()); ok {
		return strconv.Itoa(claims.UserID), true
	}
	if v := r.Context().Value(bduiUserIDKey{}); v != nil {
		if s, ok := v.(string); ok && s != "" {
			return s, true
		}
	}
	if v := r.Context().Value(testUserIDKey{}); v != nil {
		if s, ok := v.(string); ok && s != "" {
			return s, true
		}
	}
	return "", false
}
