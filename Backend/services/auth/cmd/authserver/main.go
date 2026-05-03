package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-auth/handlers"
	"github.com/alexandra-gritsaenko/gymbro-auth/service"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET is not set")
	}
	secretKey := []byte(secret)

	resendAPIKey := os.Getenv("RESEND_API_KEY")
	if resendAPIKey == "" {
		log.Fatal("RESEND_API_KEY is not set")
	}

	emailFrom := os.Getenv("AUTH_EMAIL_FROM")
	if emailFrom == "" {
		log.Fatal("AUTH_EMAIL_FROM is not set")
	}

	verifyEmailURL := os.Getenv("APP_VERIFY_EMAIL_URL")
	if verifyEmailURL == "" {
		log.Fatal("APP_VERIFY_EMAIL_URL is not set")
	}

	appEnv := os.Getenv("APP_ENV")

	db, err := sqlx.Connect("postgres", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}

	userH := handlers.NewUserHandler(db)
	emailSender := service.NewResendEmailSender(resendAPIKey, emailFrom)
	authH := handlers.NewAuthHandler(db, secretKey, emailSender, verifyEmailURL, appEnv,)

	mux := http.NewServeMux()

	authMiddleware := handlers.AuthMiddleware(secretKey)

	mux.Handle("/users", authMiddleware(userH))
	mux.Handle("/users/", authMiddleware(userH))

	mux.Handle("/auth/", authH)
	mux.Handle("/auth/logout", authMiddleware(http.HandlerFunc(authH.Logout)))

	http.ListenAndServe(":8081", mux)
}
