package handlers

import (
	"net/http"

	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
)

func requestLocale(r *http.Request) string {
	return types.NormalizeLocale(r.URL.Query().Get("locale"))
}
