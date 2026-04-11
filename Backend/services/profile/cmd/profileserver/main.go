package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-profile/handlers"
	"github.com/alexandra-gritsaenko/gymbro-profile/store"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	db, err := sqlx.Connect("postgres", databaseURL)
	if err != nil {
		log.Fatal(err)
	}

	profileH := handlers.NewProfileHandler(store.NewProfileStore(db))

	mux := http.NewServeMux()
	mux.Handle("/profiles", profileH)
	mux.Handle("/profiles/", profileH)

	log.Println("profile service listening on :8084")
	log.Fatal(http.ListenAndServe(":8084", mux))
}