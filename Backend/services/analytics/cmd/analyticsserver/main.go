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
	queryH := handlers.NewQueryHandler(analyticsStore)

	authMiddleware := handlers.AuthMiddleware(secretKey)

	agg := aggregator.New(analyticsStore)
	proc := processor.New(analyticsStore, agg, 5*time.Second, 100,)
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

	mux.Handle("/analytics/metrics/overview", authMiddleware(queryH))
	mux.Handle("/analytics/metrics/errors", authMiddleware(queryH))
	mux.Handle("/analytics/screens", authMiddleware(queryH))
	mux.Handle("/analytics/events/top", authMiddleware(queryH))
	mux.Handle("/analytics/features/usage", authMiddleware(queryH))

	mux.Handle("/analytics/funnels/workout-share", authMiddleware(queryH))
	mux.Handle("/analytics/funnels/registration-to-first-workout", authMiddleware(queryH))
	mux.Handle("/analytics/funnels/feeds-open-to-interaction", authMiddleware(queryH))
	mux.Handle("/analytics/funnels/profile-open-to-relationship-action", authMiddleware(queryH))

	mux.Handle("/analytics/retention/cohorts", authMiddleware(queryH))
	mux.Handle("/analytics/app-versions", authMiddleware(queryH))
	mux.Handle("/analytics/users/", (queryH)) // authMiddleware

	log.Println("analytics service listening on :8086")
	log.Fatal(http.ListenAndServe(":8086", mux))
}