package handlers

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"strings"

	"github.com/dgrijalva/jwt-go"
)

const (
	DefaultBduiM2MISS = "gymbro-bdui"
	DefaultBduiM2MAud = "gymbro-workouts"
	DefaultBduiM2MSub = "bdui-m2m"
)

type BduiM2MClaims struct {
	UserID string `json:"user_id"`
	jwt.StandardClaims
}

type WorkoutsAuthConfig struct {
	UserJWTSecret []byte
	BduiM2MPublic *rsa.PublicKey
	BduiM2MISS    string
	BduiM2MAud    string
}

type jwtHeaderAlg struct {
	Alg string `json:"alg"`
}

func jwtAlgorithm(token string) (string, error) {
	parts := strings.Split(token, ".")
	if len(parts) < 2 {
		return "", errors.New("invalid token format")
	}
	raw, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		raw, err = base64.URLEncoding.DecodeString(parts[0])
	}
	if err != nil {
		return "", fmt.Errorf("header decode: %w", err)
	}
	var h jwtHeaderAlg
	if err := json.Unmarshal(raw, &h); err != nil {
		return "", fmt.Errorf("header json: %w", err)
	}
	return h.Alg, nil
}

func ParseRSAPublicKeyFromPEM(b []byte) (*rsa.PublicKey, error) {
	if len(b) == 0 {
		return nil, errors.New("empty pem")
	}
	block, _ := pem.Decode(b)
	if block == nil {
		return nil, errors.New("no pem block")
	}
	pub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, err
	}
	rsaPub, ok := pub.(*rsa.PublicKey)
	if !ok {
		return nil, errors.New("not an RSA public key")
	}
	return rsaPub, nil
}

func verifyBduiM2MRS256(
	tokenString string,
	pub *rsa.PublicKey,
	expectIss, expectAud string,
) (userID string, err error) {
	if pub == nil {
		return "", errors.New("no bdui public key configured")
	}
	claims := &BduiM2MClaims{}
	_, err = jwt.ParseWithClaims(tokenString, claims, func(t *jwt.Token) (interface{}, error) {
		if t.Method != jwt.SigningMethodRS256 {
			return nil, errors.New("only RS256 allowed for bdui m2m")
		}
		return pub, nil
	})
	if err != nil {
		return "", err
	}
	if strings.TrimSpace(claims.UserID) == "" {
		return "", errors.New("empty user_id claim")
	}
	if expectIss != "" && claims.Issuer != expectIss {
		return "", errors.New("invalid iss")
	}
	if expectAud != "" && claims.Audience != expectAud {
		return "", errors.New("invalid aud")
	}
	if err := claims.Valid(); err != nil {
		return "", err
	}
	if claims.Subject != DefaultBduiM2MSub {
		return "", errors.New("invalid sub")
	}
	return claims.UserID, nil
}
