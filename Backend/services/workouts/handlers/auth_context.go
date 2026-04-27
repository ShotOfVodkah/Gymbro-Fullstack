package handlers

import (
	"context"
	"net/http"
	"strconv"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
)

type testUserIDKey struct{}
type bduiUserIDKey struct{}

func AuthMiddleware(secret []byte) func(http.Handler) http.Handler {
	return authmw.Middleware(authmw.Config{
		Secret:       secret,
		Unauthorized: unauthorized,
	})
}

func WorkoutsAuthMiddleware(cfg WorkoutsAuthConfig) func(http.Handler) http.Handler {
	jwtMW := authmw.Middleware(authmw.Config{
		Secret:       cfg.UserJWTSecret,
		Unauthorized: unauthorized,
	})
	iss := strings.TrimSpace(cfg.BduiM2MISS)
	if iss == "" {
		iss = DefaultBduiM2MISS
	}
	aud := strings.TrimSpace(cfg.BduiM2MAud)
	if aud == "" {
		aud = DefaultBduiM2MAud
	}
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			auth := r.Header.Get("Authorization")
			tokenString := ""
			if auth != "" && strings.HasPrefix(auth, "Bearer ") {
				tokenString = strings.TrimSpace(strings.TrimPrefix(auth, "Bearer "))
			}
			if tokenString == "" {
				unauthorized(w, r)
				return
			}
			alg, err := jwtAlgorithm(tokenString)
			if err != nil {
				unauthorized(w, r)
				return
			}
			switch alg {
			case "HS256":
				jwtMW(next).ServeHTTP(w, r)
			case "RS256":
				uid, vErr := verifyBduiM2MRS256(tokenString, cfg.BduiM2MPublic, iss, aud)
				if vErr != nil {
					unauthorized(w, r)
					return
				}
				ctx := context.WithValue(r.Context(), bduiUserIDKey{}, uid)
				next.ServeHTTP(w, r.WithContext(ctx))
			default:
				unauthorized(w, r)
			}
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
