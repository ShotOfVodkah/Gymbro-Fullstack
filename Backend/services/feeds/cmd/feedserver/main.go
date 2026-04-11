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

	profileBaseURL := os.Getenv("PROFILE_SERVICE_URL")
	if profileBaseURL == "" {
		log.Fatal("PROFILE_SERVICE_URL is not set")
	}

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	db, err := sqlx.Connect("postgres", databaseURL)
	if err != nil {
		log.Fatal(err)
	}

	workoutsClient := clients.NewWorkoutsClient(workoutsBaseURL)
	workoutsCalendarClient := clients.NewWorkoutsCalendarClient(workoutsBaseURL)
	profileClient := clients.NewProfileClient(profileBaseURL)

	feedStore := store.NewFeedStore(db)
	calendarStore := store.NewCalendarStore(db)

	feedH := handlers.NewFeedHandler(feedStore, workoutsClient)
	calendarH := handlers.NewCalendarHandler(calendarStore, profileClient, workoutsCalendarClient)
	authMiddleware := handlers.AuthMiddleware(secretKey)

	mux := http.NewServeMux()
	
	mux.Handle("/feed", authMiddleware(feedH))
	mux.Handle("/feed/", authMiddleware(feedH))

	mux.Handle("/communities", authMiddleware(feedH))
	mux.Handle("/communities/", authMiddleware(feedH))

	mux.Handle("/calendar/people", authMiddleware(calendarH))
	mux.Handle("/calendar/month", authMiddleware(calendarH))

	log.Println("feeds service listening on :8083")
	log.Fatal(http.ListenAndServe(":8083", mux))
}