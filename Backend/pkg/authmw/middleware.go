package authmw

import (
	"context"
	"net/http"
	"strings"

	"github.com/dgrijalva/jwt-go"
)

type Claims struct {
	UserID    int    `json:"user_id"`
	Email     string `json:"email"`
	Role      string `json:"role"`
	SessionID string `json:"session_id"`
	jwt.StandardClaims
}

type ctxKey string

const claimsCtxKey ctxKey = "gymbro.jwt.claims"

type Config struct {
	Secret       []byte
	Unauthorized func(w http.ResponseWriter, r *http.Request)
}

func Middleware(cfg Config) func(http.Handler) http.Handler {
	unauth := cfg.Unauthorized
	if unauth == nil {
		unauth = defaultUnauthorized
	}
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
				unauth(w, r)
				return
			}
			tokenString := strings.TrimPrefix(authHeader, "Bearer ")
			token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(t *jwt.Token) (interface{}, error) {
				return cfg.Secret, nil
			})
			if err != nil {
				unauth(w, r)
				return
			}
			claims, ok := token.Claims.(*Claims)
			if !ok || !token.Valid || claims.Valid() != nil {
				unauth(w, r)
				return
			}
			ctx := context.WithValue(r.Context(), claimsCtxKey, claims)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func defaultUnauthorized(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusUnauthorized)
	_, _ = w.Write([]byte(`{"error":"unauthorized"}`))
}

func GetClaims(ctx context.Context) (*Claims, bool) {
	c, ok := ctx.Value(claimsCtxKey).(*Claims)
	if !ok || c == nil {
		return nil, false
	}
	return c, true
}

func ContextWithClaims(ctx context.Context, c *Claims) context.Context {
	return context.WithValue(ctx, claimsCtxKey, c)
}
