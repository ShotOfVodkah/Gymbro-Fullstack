package main

import (
	"log"
	"net/http"
	"os"

	"github.com/alexandra-gritsaenko/gymbro-feeds/clients"
	"github.com/alexandra-gritsaenko/gymbro-feeds/handlers"
	"github.com/alexandra-gritsaenko/gymbro-feeds/handlers/chats"
	"github.com/alexandra-gritsaenko/gymbro-feeds/handlers/feeds"
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

	perksBaseURL := os.Getenv("PERKS_SERVICE_URL")
	if perksBaseURL == "" {
		log.Fatal("PERKS_SERVICE_URL is not set")
	}

	internalSecret := os.Getenv("INTERNAL_SERVICE_SECRET")
	if internalSecret == "" {
		log.Fatal("INTERNAL_SERVICE_SECRET is not set")
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
	perksClient := clients.NewPerksClient(perksBaseURL, internalSecret)

	feedStore := store.NewFeedStore(db)
	calendarStore := store.NewCalendarStore(db)
	peopleStore := store.NewPeopleStore(db)
	chatStore := store.NewChatStore(db)

	chatEventHub := chats.NewChatEventHub()

	feedH := feeds.NewFeedHandler(feedStore, chatStore, workoutsClient, profileClient, perksClient)
	calendarH := handlers.NewCalendarHandler(&calendarStore, profileClient, workoutsCalendarClient)
	peopleH := handlers.NewPeopleHandler(peopleStore, profileClient)
	internalPeopleH := handlers.NewInternalPeopleHandler(peopleStore)
	internalChatH := chats.NewInternalChatHandler(chatStore)
	chatH := chats.NewChatHandler(chatStore, profileClient, workoutsClient, chatEventHub)
	authMiddleware := handlers.AuthMiddleware(secretKey)

	mux := http.NewServeMux()

	mux.Handle("/feed", authMiddleware(feedH))
	mux.Handle("/feed/", authMiddleware(feedH))
	mux.Handle("/communities", authMiddleware(feedH))
	mux.Handle("/communities/", authMiddleware(feedH))
	mux.Handle("/posts", authMiddleware(feedH))
	mux.Handle("/posts/", authMiddleware(feedH))

	mux.Handle("/calendar/people", authMiddleware(calendarH))
	mux.Handle("/calendar/month", authMiddleware(calendarH))

	mux.Handle("/people/friends", authMiddleware(peopleH))
	mux.Handle("/people/following", authMiddleware(peopleH))
	mux.Handle("/people/discover", authMiddleware(peopleH))
	mux.Handle("/people/", authMiddleware(peopleH))

	mux.Handle("/chats/direct", authMiddleware(chatH))
	mux.Handle("/chats/group", authMiddleware(chatH))
	mux.Handle("/chats/", authMiddleware(chatH))
	mux.Handle("/messages/", authMiddleware(chatH))

	mux.Handle("/shares/workout", authMiddleware(feedH))
	mux.Handle("/internal/people/", internalPeopleH)
	mux.Handle("/internal/chats/", internalChatH)

	log.Println("feeds service listening on :8083")
	log.Fatal(http.ListenAndServe(":8083", mux))
}