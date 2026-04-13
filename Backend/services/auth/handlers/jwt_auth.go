package handlers

import (
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
)

func AuthMiddleware(secret []byte) func(http.Handler) http.Handler {
	return authmw.Middleware(authmw.Config{
		Secret:       secret,
		Unauthorized: unauthorized,
	})
}
