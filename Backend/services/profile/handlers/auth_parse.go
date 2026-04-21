package handlers

import (
	"errors"
	"net/http"
	"strings"

	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/dgrijalva/jwt-go"
)

var errNoBearer = errors.New("missing bearer token")

func parseClaims(authHeader string, secret []byte) (*authmw.Claims, error) {
	if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
		return nil, errNoBearer
	}
	tokenString := strings.TrimPrefix(authHeader, "Bearer ")
	token, err := jwt.ParseWithClaims(tokenString, &authmw.Claims{}, func(t *jwt.Token) (interface{}, error) {
		return secret, nil
	})
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(*authmw.Claims)
	if !ok || !token.Valid || claims.Valid() != nil {
		return nil, jwt.ErrSignatureInvalid
	}
	return claims, nil
}

func parseClaimsFromRequest(r *http.Request, secret []byte) (*authmw.Claims, error) {
	return parseClaims(r.Header.Get("Authorization"), secret)
}
