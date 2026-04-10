package main

import (
	"log"
	"net/http"
	"os"

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
	sessionH := handlers.NewSessionHandler(db)
	authMiddleware := handlers.AuthMiddleware(secretKey)

	mux := http.NewServeMux()
	mux.Handle("/workouts/", authMiddleware(workoutH))
	mux.Handle("/workouts", authMiddleware(workoutH))
	mux.Handle("/exercises", exerciseH)
	mux.Handle("/sessions", authMiddleware(sessionH))
	mux.Handle("/sessions/", authMiddleware(sessionH))

	log.Println("workouts service listening on :8082")
	log.Fatal(http.ListenAndServe(":8082", mux))
}
