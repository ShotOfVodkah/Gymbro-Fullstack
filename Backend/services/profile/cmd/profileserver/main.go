package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-profile/clients"
	"github.com/alexandra-gritsaenko/gymbro-profile/handlers"
	"github.com/alexandra-gritsaenko/gymbro-profile/store"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET is not set")
	}

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	db, err := sqlx.Connect("postgres", databaseURL)
	if err != nil {
		log.Fatal(err)
	}

	feedsURL := os.Getenv("FEEDS_SERVICE_URL")
	feedsClient := clients.NewFeedsPeopleClient(feedsURL)
	internalSecret := os.Getenv("INTERNAL_SERVICE_SECRET")
	workoutsURL := os.Getenv("WORKOUTS_SERVICE_URL")
	workoutsTemporal := clients.NewWorkoutsTemporalClient(workoutsURL, internalSecret)

	profileH := handlers.NewProfileHandler(store.NewProfileStore(db), []byte(secret), feedsClient, internalSecret, workoutsTemporal)

	mux := http.NewServeMux()
	mux.Handle("/profiles", profileH)
	mux.Handle("/profiles/", profileH)

	log.Println("profile service listening on :8084")
	log.Fatal(http.ListenAndServe(":8084", mux))
}
