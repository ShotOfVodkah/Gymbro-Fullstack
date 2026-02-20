package handlers

import (
	"context"
	"net/http"
	"strings"

	"github.com/dgrijalva/jwt-go"
)

type contextKey string

const (
	ContextUserIDKey contextKey = "userID"
	ContextEmailKey  contextKey = "email"
	ContextRoleKey   contextKey = "role"
)

type CustomClaims struct {
	UserID int    `json:"user_id"`
	Email  string `json:"email"`
	Role   string `json:"role"`
	jwt.StandardClaims
}

func AuthMiddleware(key []byte) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				unauthorized(w, r)
				return
			}

			if !strings.HasPrefix(authHeader, "Bearer ") {
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

			ctx := context.WithValue(r.Context(), ContextUserIDKey, claims.UserID)
			ctx = context.WithValue(ctx, ContextEmailKey, claims.Email)
			ctx = context.WithValue(ctx, ContextRoleKey, claims.Role)

			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}
