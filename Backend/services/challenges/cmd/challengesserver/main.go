package main

import (
	"log"
	"net/http"
	"os"
	"context"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"

	"github.com/alexandra-gritsaenko/gymbro-challenges/clients"
	"github.com/alexandra-gritsaenko/gymbro-challenges/handler"
	"github.com/alexandra-gritsaenko/gymbro-challenges/middleware"
	"github.com/alexandra-gritsaenko/gymbro-challenges/service"
	"github.com/alexandra-gritsaenko/gymbro-challenges/store"
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

	internalSecret := os.Getenv("INTERNAL_SERVICE_SECRET")
	if internalSecret == "" {
		log.Fatal("INTERNAL_SERVICE_SECRET is required")
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

	analyticsURL := os.Getenv("ANALYTICS_SERVICE_URL")
	if analyticsURL == "" {
		analyticsURL = "http://analytics_service:8086"
	}

	// perksURL := os.Getenv("PERKS_SERVICE_URL")
	// if perksURL == "" {
	// 	perksURL = "http://perks_service:8087"
	// }

	chatsClient := clients.NewHTTPChatsClient(feedsURL, internalSecret)
	analyticsClient := clients.NewAnalyticsClient(analyticsURL, internalSecret)

	challengesStore := store.NewPostgresChallengeStore(db)
	challengesService := service.NewChallengesService(challengesStore, chatsClient, analyticsClient,)
	service.StartChallengeFinalizerCron(context.Background(), challengesService,)
	challengesHandler := handler.NewChallengesHandler(challengesService)
	authMiddleware := middleware.AuthMiddleware([]byte(jwtSecret))

	mux := http.NewServeMux()

	mux.Handle("/challenges", authMiddleware(challengesHandler))
	mux.Handle("/challenges/", authMiddleware(challengesHandler))

	mux.Handle("/internal/challenges/events/workout-completed", challengesHandler)

	mux.HandleFunc("/challenges/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("content-type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"ok":true}`))
	})

	mux.HandleFunc("/challenges/ready", func(w http.ResponseWriter, r *http.Request) {
		if err := db.Ping(); err != nil {
			w.Header().Set("content-type", "application/json")
			w.WriteHeader(http.StatusServiceUnavailable)
			_, _ = w.Write([]byte(`{"ready":false}`))
			return
		}

		w.Header().Set("content-type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"ready":true}`))
	})

	log.Println("challenges service listening on :8088")
	log.Fatal(http.ListenAndServe(":8088", mux))
}