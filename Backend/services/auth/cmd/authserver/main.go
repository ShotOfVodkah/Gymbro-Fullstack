package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-auth/handlers"
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

	userH := handlers.NewUserHandler(db)
	authH := handlers.NewAuthHandler(db, secretKey)

	mux := http.NewServeMux()

	authMiddleware := handlers.AuthMiddleware(secretKey)

	mux.Handle("/users", authMiddleware(userH))
	mux.Handle("/users/", authMiddleware(userH))

	mux.Handle("/auth/", authH)
	mux.Handle("/auth/logout", authMiddleware(http.HandlerFunc(authH.Logout)))

	http.ListenAndServe(":8081", mux)
}
