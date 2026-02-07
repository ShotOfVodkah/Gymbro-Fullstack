package main

import (
	"net/http"
)

var secretKey = []byte("8ce7376694b4418e69f35a225d8cb349dbc32f7c5ba853dcc4d6cfa7b7050c54") // head -c 32 /dev/urandom | shasum -a 256

func main() {
	mux := http.NewServeMux()

	userH := NewUserHandler()
	authH := NewAuthHandler()

	mux.Handle("/users", userH)
	mux.Handle("/users/", userH)
	mux.Handle("/auth", authH)

	http.ListenAndServe("localhost:8080", mux)
}