package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-workouts/handlers"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	db, err := sqlx.Connect("postgres", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}

	workoutH := handlers.NewWorkoutHandler(db)

	mux := http.NewServeMux()
	mux.Handle("/workouts/", workoutH)

	log.Println("workouts service listening on :8082")
	log.Fatal(http.ListenAndServe(":8082", mux))
}
