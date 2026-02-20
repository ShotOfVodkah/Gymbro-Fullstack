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

	mux.HandleFunc("/users", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodPost {
			userH.CreateUser(w, r)
			return
		}
		authMiddleware(userH).ServeHTTP(w, r)
	})
	mux.Handle("/users/", authMiddleware(userH))
	// mux.Handle("/auth", authH)
	// mux.Handle("/refresh", authH)
	// mux.Handle("/logout", authH)
	
	// AUTH (login/refresh/logout)
	mux.Handle("/auth/", authH)

	http.ListenAndServe(":8081", mux)
}
