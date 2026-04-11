package main

import (
	"log"
	"net/http"
	"os"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

type App struct {
	DB *sqlx.DB
}

func main() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("DATABASE_URL is required")
	}

	db, err := sqlx.Connect("postgres", dsn)
	if err != nil {
		log.Fatalf("db connect error: %v", err)
	}

	app := &App{DB: db}

	mux := http.NewServeMux()

	// feed
	mux.HandleFunc("/feed", app.GetFeed)

	log.Println("feeds service listening on :8083")
	log.Fatal(http.ListenAndServe(":8083", mux))
}

func (a *App) GetFeed(w http.ResponseWriter, r *http.Request) {}