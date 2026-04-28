package main

import (
	"log"
	"net/http"
	"os"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"

	"github.com/alexandra-gritsaenko/gymbro-perks/achievements"
	"github.com/alexandra-gritsaenko/gymbro-perks/handlers"
	"github.com/alexandra-gritsaenko/gymbro-perks/leaderboard"
	"github.com/alexandra-gritsaenko/gymbro-perks/service"
	"github.com/alexandra-gritsaenko/gymbro-perks/store"
	"github.com/alexandra-gritsaenko/gymbro-perks/streak"
	"github.com/alexandra-gritsaenko/gymbro-perks/clients"
)

func main() {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("DATABASE_URL is required")
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("JWT_SECRET is required")
	}

	db, err := sqlx.Connect("postgres", databaseURL)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer db.Close()

	feedsURL := os.Getenv("FEEDS_SERVICE_URL")
	if feedsURL == "" {
		feedsURL = "http://feeds_service:8083"
	}

	internalSecret := os.Getenv("INTERNAL_SERVICE_SECRET")
	if internalSecret == "" {
		log.Fatal("INTERNAL_SERVICE_SECRET is required")
	}

	feedsClient := clients.NewFeedsClient(feedsURL, internalSecret)

	baseStore := store.NewPerksStore(db)
	streakStore := streak.NewStore(db, baseStore)
	achievementStore := achievements.NewStore(db, baseStore)
	leaderboardStore := leaderboard.NewStore(db, baseStore, feedsClient)

	perksService := service.NewPerksService(
		baseStore,
		streakStore,
		achievementStore,
		leaderboardStore,
	)

	perksHandler := handlers.NewPerksHandler(perksService)
	internalPerksHandler := handlers.NewInternalPerksHandler(perksService)
	authMiddleware := handlers.AuthMiddleware([]byte(jwtSecret))

	mux := http.NewServeMux()

	mux.Handle("/perks/me", authMiddleware(perksHandler))
	mux.Handle("/perks/streak", authMiddleware(perksHandler))
	mux.Handle("/perks/streak/goal", authMiddleware(perksHandler))
	mux.Handle("/perks/streak/freeze/use", authMiddleware(perksHandler))
	mux.Handle("/perks/achievements", authMiddleware(perksHandler))
	mux.Handle("/perks/leaderboard", authMiddleware(perksHandler))
	mux.Handle("/perks/events", authMiddleware(perksHandler))

	mux.Handle("/internal/perks/users/", internalPerksHandler)

	mux.HandleFunc("/perks/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("content-type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"ok":true}`))
	})

	log.Println("perks service listening on :8087")
	log.Fatal(http.ListenAndServe(":8087", mux))
}