package handlers

import (
	"encoding/json"
	"net/http"
)

func notFound(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"error":"not found"}`))
}

func badRequest(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusBadRequest)
	w.Write([]byte(`{"error":"bad request"}`))
}

func internalServerError(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusInternalServerError)
	w.Write([]byte(`{"error":"internal server error"}`))
}

func unauthorized(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusUnauthorized)
	w.Write([]byte(`{"error":"unauthorized"}`))
}

func forbidden(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusForbidden)
	w.Write([]byte(`{"error":"forbidden"}`))
}

func conflict(w http.ResponseWriter, r *http.Request, msg string) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusConflict)
	if msg == "" {
		msg = "conflict"
	}
	_ = json.NewEncoder(w).Encode(map[string]string{"error": msg})
}