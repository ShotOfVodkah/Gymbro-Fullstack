package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
)

type Route struct {
	Prefix string
	EnvKey string
	Default string
}

func newProxy(target string) *httputil.ReverseProxy {
	u, err := url.Parse(target)
	if err != nil {
		log.Fatal(err)
	}
	return httputil.NewSingleHostReverseProxy(u)
}

func envOr(key, fallback string) string {
	v := strings.TrimSpace(os.Getenv(key))
	if v == "" {
		return fallback
	}
	return v
}

func mount(mux *http.ServeMux, prefix string, h http.Handler) {
	mux.Handle(prefix, h)
	if !strings.HasSuffix(prefix, "/") {
		mux.Handle(prefix+"/", h)
	}
}

func main() {
	routes := []Route{
		{Prefix: "/auth", EnvKey: "AUTH_URL", Default: "http://auth_service:8081"},
		{Prefix: "/users", EnvKey: "AUTH_URL", Default: "http://auth_service:8081"},

		{Prefix: "/workouts", EnvKey: "WORKOUTS_URL", Default: "http://workouts_service:8082"},
		{Prefix: "/exercises", EnvKey: "WORKOUTS_URL", Default: "http://workouts_service:8082"},
		{Prefix: "/sessions", EnvKey: "WORKOUTS_URL", Default: "http://workouts_service:8082"},

		{Prefix: "/feed", EnvKey: "FEEDS_URL", Default: "http://feeds_service:8083"},
		{Prefix: "/communities", EnvKey: "FEEDS_URL", Default: "http://feeds_service:8083"},
		{Prefix: "/calendar", EnvKey: "FEEDS_URL", Default: "http://feeds_service:8083"},
		{Prefix: "/people", EnvKey: "FEEDS_URL", Default: "http://feeds_service:8083"},
		{Prefix: "/chats", EnvKey: "FEEDS_URL", Default: "http://feeds_service:8083"},
		{Prefix: "/messages", EnvKey: "FEEDS_URL", Default: "http://feeds_service:8083"},
		{Prefix: "/posts", EnvKey: "FEEDS_URL", Default: "http://feeds_service:8083"},
		{Prefix: "/shares", EnvKey: "FEEDS_URL", Default: "http://feeds_service:8083"},

		{Prefix: "/profiles", EnvKey: "PROFILE_URL", Default: "http://profile_service:8084"},

		{Prefix: "/ai", EnvKey: "AI_URL", Default: "http://ai_service:8085"},
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("content-type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"ok":true}`))
	})


	proxies := map[string]http.Handler{}
	for _, rt := range routes {
		target := envOr(rt.EnvKey, rt.Default)
		p, ok := proxies[target]
		if !ok {
			p = newProxy(target)
			proxies[target] = p
		}
		mount(mux, rt.Prefix, p)
		log.Printf("route %s -> %s", rt.Prefix, target)
	}

	log.Println("gateway listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
