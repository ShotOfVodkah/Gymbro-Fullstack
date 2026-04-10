package handlers

import (
	"context"
	"net/http"
	"strconv"
	"strings"

	"github.com/dgrijalva/jwt-go"
)

type contextKey string

const ContextUserIDKey contextKey = "userID"

type CustomClaims struct {
	UserID int `json:"user_id"`
	jwt.StandardClaims
}

func AuthMiddleware(key []byte) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
				unauthorized(w, r)
				return
			}

			tokenString := strings.TrimPrefix(authHeader, "Bearer ")
			token, err := jwt.ParseWithClaims(tokenString, &CustomClaims{}, func(t *jwt.Token) (interface{}, error) {
				return key, nil
			})
			if err != nil {
				unauthorized(w, r)
				return
			}

			claims, ok := token.Claims.(*CustomClaims)
			if !ok || claims.Valid() != nil {
				unauthorized(w, r)
				return
			}

			ctx := context.WithValue(r.Context(), ContextUserIDKey, strconv.Itoa(claims.UserID))
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func userIDFromContext(r *http.Request) (string, bool) {
	value := r.Context().Value(ContextUserIDKey)
	if value == nil {
		return "", false
	}
	userID, ok := value.(string)
	if !ok || userID == "" {
		return "", false
	}
	return userID, true
}
