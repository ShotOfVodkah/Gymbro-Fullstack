package main

import (
	"sync"
	"github.com/dgrijalva/jwt-go"
)

type user struct {
	ID string `json:"ID"`
	Name string `json:"Name"`
}

type CustomClaims struct {
	Username string
	jwt.StandardClaims
}

type datastore struct {
	m map[string]user
	*sync.RWMutex
}

type userHandler struct {
	key []byte
	store *datastore
}

type authHandler struct {
	key []byte
}