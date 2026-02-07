package main

import (
	"net/http"
	"fmt"
	"regexp"
	"github.com/dgrijalva/jwt-go"
)


var (
	headerTokenRe = regexp.MustCompile(`^Bearer\s([a-zA-Z0-9\.\-_]+)$`)
)


func authorizer(key []byte) func(w http.ResponseWriter, r *http.Request) bool {
	return func(w http.ResponseWriter, r *http.Request) bool {
		matches := headerTokenRe.FindStringSubmatch(r.Header.Get("Authorization"))
		if len(matches) < 2 {
			return false
		}
		token, err := jwt.ParseWithClaims(matches[1], &CustomClaims{}, func(t *jwt.Token) (interface{}, error) {
			return key, nil
		})
		if err != nil {
			return false
		}
		tkn, ok := token.Claims.(*CustomClaims)
		if !ok {
			return false
		}
		if err := tkn.Valid(); err != nil {
			return false
		}
		fmt.Printf("%+v", tkn)
		return true
	}
}