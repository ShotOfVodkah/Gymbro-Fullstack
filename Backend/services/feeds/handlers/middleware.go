package handlers

import (
	"context"
	"net/http"
	"strings"

	"github.com/dgrijalva/jwt-go"
)

type CustomClaims struct {
	UserID    int    `json:"user_id"`
	Email  string `json:"email"`
	Role   string `json:"role"`
	SessionID string `json:"session_id"`
	jwt.StandardClaims
}

type contextKey string

const claimsKey contextKey = "claims"

func AuthMiddleware(secretKey []byte) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				http.Error(w, "missing authorization header", http.StatusUnauthorized)
				return
			}

			parts := strings.SplitN(authHeader, " ", 2)
			if len(parts) != 2 || parts[0] != "Bearer" {
				http.Error(w, "invalid authorization header", http.StatusUnauthorized)
				return
			}

			tokenStr := parts[1]

			token, err := jwt.ParseWithClaims(tokenStr, &CustomClaims{}, func(token *jwt.Token) (interface{}, error) {
				return secretKey, nil
			})
			if err != nil {
				http.Error(w, "invalid token", http.StatusUnauthorized)
				return
			}

			claims, ok := token.Claims.(*CustomClaims)
			if !ok || !token.Valid {
				http.Error(w, "invalid token claims", http.StatusUnauthorized)
				return
			}

			ctx := context.WithValue(r.Context(), claimsKey, claims)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func GetClaims(ctx context.Context) (*CustomClaims, bool) {
	claims, ok := ctx.Value(claimsKey).(*CustomClaims)
	return claims, ok
}