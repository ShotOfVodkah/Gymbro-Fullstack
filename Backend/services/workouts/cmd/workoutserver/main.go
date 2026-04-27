package main

import (
	"crypto/rsa"
	"log"
	"net/http"
	"os"
	"strings"

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

	var bduiPub *rsa.PublicKey
	if pemStr := strings.TrimSpace(os.Getenv("BDUI_M2M_JWT_PUBLIC_KEY_PEM")); pemStr != "" {
		pk, err := handlers.ParseRSAPublicKeyFromPEM([]byte(pemStr))
		if err != nil {
			log.Fatalf("BDUI_M2M_JWT_PUBLIC_KEY_PEM: %v", err)
		}
		bduiPub = pk
	}

	authCfg := handlers.WorkoutsAuthConfig{
		UserJWTSecret: secretKey,
		BduiM2MPublic: bduiPub,
		BduiM2MISS:    os.Getenv("BDUI_M2M_JWT_ISS"),
		BduiM2MAud:    os.Getenv("BDUI_M2M_JWT_AUD"),
	}
	authMiddleware := handlers.WorkoutsAuthMiddleware(authCfg)

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
