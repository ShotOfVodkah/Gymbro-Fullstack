package middleware

import (
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
)

func challengesUnauthorized(w http.ResponseWriter, r *http.Request) {
	http.Error(w, "invalid token", http.StatusUnauthorized)
}

func AuthMiddleware(secret []byte) func(http.Handler) http.Handler {
	return authmw.Middleware(authmw.Config{
		Secret:       secret,
		Unauthorized: challengesUnauthorized,
	})
}
