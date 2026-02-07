package main

import (
	"encoding/json"
	"net/http"
	"time"
	"github.com/dgrijalva/jwt-go"
)


func (h *authHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	switch {
		case r.Method == http.MethodPost:
			h.Token(w, r)
			return
		default:
			notFound(w, r)
			return
	}
}


func (h *authHandler) Token(w http.ResponseWriter, r *http.Request) {
	req := struct {
		User, Password string
	}{}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		internalServerError(w, r)
		return
	}
	if !checkCredentials(req.User, req.Password) {
		unauthorized(w, r)
		return
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, CustomClaims{
		Username: req.User, 
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().AddDate(0, 0, 1).Unix(),
			Issuer: "https://gymbro.fullstack",
		},
	})
	tkn, err := token.SignedString(h.key)
	if err != nil {
		unauthorized(w, r)
		return 
	}
	jsonBytes, err := json.Marshal(struct{JWT string}{JWT: tkn})
	if err != nil {
		unauthorized(w, r)
		return 
	}
	w.WriteHeader(http.StatusOK)
	w.Write(jsonBytes)
}


func checkCredentials(user, password string) bool {
	return user == "admin" && password == "secret"
}


func NewAuthHandler() *authHandler {
	return &authHandler{key: secretKey}
}