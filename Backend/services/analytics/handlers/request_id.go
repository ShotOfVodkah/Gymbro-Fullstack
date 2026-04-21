package handlers

import (
	"net/http"

	"github.com/google/uuid"
)

func getOrCreateRequestID(r *http.Request) string {
	requestID := r.Header.Get("X-Request-Id")
	if requestID == "" {
		requestID = uuid.NewString()
	}
	return requestID
}