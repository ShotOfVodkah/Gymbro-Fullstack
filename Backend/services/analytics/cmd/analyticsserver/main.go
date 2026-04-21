package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-analytics/aggregator"
	"github.com/alexandra-gritsaenko/gymbro-analytics/handlers"
	"github.com/alexandra-gritsaenko/gymbro-analytics/processor"
	"github.com/alexandra-gritsaenko/gymbro-analytics/scheduler"
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

	analyticsStore := store.NewAnalyticsStore(db)
	analyticsH := handlers.NewAnalyticsHandler(analyticsStore)

	authMiddleware := handlers.AuthMiddleware(secretKey)

	agg := aggregator.New()
	proc := processor.New(
		analyticsStore,
		agg,
		5*time.Second,
		100,
	)

	ctx := context.Background()
	sched := scheduler.New(proc)
	sched.Start(ctx)

	mux := http.NewServeMux()

	mux.Handle("/analytics/health", healthH)
	mux.Handle("/analytics/ready", healthH)

	mux.Handle("/analytics/events", authMiddleware(analyticsH))
	mux.Handle("/analytics/events/", authMiddleware(analyticsH))
	mux.Handle("/analytics/events/batch", authMiddleware(analyticsH))
	mux.Handle("/analytics/events/batch/", authMiddleware(analyticsH))

	log.Println("analytics service listening on :8086")
	log.Fatal(http.ListenAndServe(":8086", mux))
}