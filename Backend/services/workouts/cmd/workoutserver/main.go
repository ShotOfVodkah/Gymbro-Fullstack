package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-workouts/clients"
	"github.com/alexandra-gritsaenko/gymbro-workouts/handlers"
	"github.com/alexandra-gritsaenko/gymbro-workouts/store"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET is not set")
	}
	secretKey := []byte(secret)

	db, err := sqlx.Connect("postgres", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}

	workoutH := handlers.NewWorkoutHandler(store.NewWorkoutStore(db))
	exerciseH := handlers.NewExerciseHandler(db)

	profileURL := os.Getenv("PROFILE_SERVICE_URL")
	internalSecret := os.Getenv("INTERNAL_SERVICE_SECRET")
	profileStatsClient := clients.NewProfileStatsClient(profileURL, internalSecret)
	sessionH := handlers.NewSessionHandler(db, profileStatsClient)
	bduiSecret := os.Getenv("BDUI_TO_WORKOUTS_SECRET")
	if bduiSecret == "" {
		bduiSecret = "bdui_to_workouts_dev_change_me"
	}
	authMiddleware := handlers.WorkoutsAuthMiddleware(secretKey, bduiSecret)

	mux := http.NewServeMux()
	mux.Handle("/workouts/", authMiddleware(workoutH))
	mux.Handle("/workouts", authMiddleware(workoutH))
	mux.Handle("/exercises", exerciseH)
	mux.Handle("/sessions/preview/batch", sessionH)
	mux.Handle("/sessions/save-as-workout", authMiddleware(sessionH))
	mux.Handle("/sessions/save-as-workout/", authMiddleware(sessionH))
	mux.Handle("/sessions/calendar", sessionH)
	mux.Handle("/sessions", authMiddleware(sessionH))
	mux.Handle("/sessions/", authMiddleware(sessionH))

	log.Println("workouts service listening on :8082")
	log.Fatal(http.ListenAndServe(":8082", mux))
}
