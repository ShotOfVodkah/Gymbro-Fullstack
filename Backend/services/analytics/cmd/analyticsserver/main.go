package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-analytics/handlers"
	"github.com/alexandra-gritsaenko/gymbro-analytics/store"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET is not set")
	}
	secretKey := []byte(secret)

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	db, err := sqlx.Connect("postgres", databaseURL)
	if err != nil {
		log.Fatal(err)
	}

	healthStore := store.NewHealthStore(db)
	healthH := handlers.NewHealthHandler(healthStore)

	authMiddleware := handlers.AuthMiddleware(secretKey)

	mux := http.NewServeMux()

	mux.Handle("/analytics/health", healthH)
	mux.Handle("/analytics/ready", healthH)

	// задел под следующий этап
	mux.Handle("/analytics/events", authMiddleware(notImplementedHandler()))
	mux.Handle("/analytics/events/", authMiddleware(notImplementedHandler()))

	log.Println("analytics service listening on :8086")
	log.Fatal(http.ListenAndServe(":8086", mux))
}

func notImplementedHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusNotImplemented)
		w.Write([]byte(`{"message":"analytics events ingestion is not implemented yet"}`))
	})
}