package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/handlers"
	"github.com/alexandra-gritsaenko/gymbro-feeds/store"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET is not set")
	}
	secretKey := []byte(secret)

	workoutsBaseURL := os.Getenv("WORKOUTS_SERVICE_URL")
	if workoutsBaseURL == "" {
		log.Fatal("WORKOUTS_SERVICE_URL is not set")
	}

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	db, err := sqlx.Connect("postgres", databaseURL)
	if err != nil {
		log.Fatal(err)
	}

	feedStore := store.NewFeedStore(db)
	workoutsClient := clients.NewWorkoutsClient(workoutsBaseURL)

	feedH := handlers.NewFeedHandler(feedStore, workoutsClient)
	authMiddleware := handlers.AuthMiddleware(secretKey)

	mux := http.NewServeMux()
	mux.Handle("/feed", authMiddleware(feedH))
	mux.Handle("/feed/", authMiddleware(feedH))

	log.Println("feeds service listening on :8083")
	log.Fatal(http.ListenAndServe(":8083", mux))
}