package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"github.com/alexandra-gritsaenko/gymbro-backend/service"
	"github.com/alexandra-gritsaenko/gymbro-backend/store"
	"github.com/dgrijalva/jwt-go"
	"github.com/jmoiron/sqlx"
	"net/http"
	"time"
)

type authHandler struct {
	key          []byte
	userService  service.UserService
	refreshStore store.RefreshStore
}

func (h *authHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	switch {
	case r.Method == http.MethodPost && r.URL.Path == "/auth":
		h.Token(w, r)
	case r.Method == http.MethodPost && r.URL.Path == "/refresh":
		h.Refresh(w, r)
	case r.Method == http.MethodPost && r.URL.Path == "/logout":
		h.Logout(w, r)
	default:
		notFound(w, r)
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
	user, err := h.userService.AuthenticateUserByEmailPassword(req.User, req.Password)
	if err != nil {
		unauthorized(w, r)
		return
	}
	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, CustomClaims{
		UserID: user.ID,
		Email:  user.Email,
		Role:   user.Role,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(15 * time.Minute).Unix(), // 15 minutes
			Issuer:    "gymbro",
		},
	})
	accessString, err := accessToken.SignedString(h.key)
	if err != nil {
		unauthorized(w, r)
		return
	}

	refreshBytes := make([]byte, 32)
	rand.Read(refreshBytes)
	refreshToken := hex.EncodeToString(refreshBytes)
	refreshExpires := time.Now().Add(7 * 24 * time.Hour) // a week

	err = h.refreshStore.Save(user.ID, refreshToken, refreshExpires)
	if err != nil {
		internalServerError(w, r)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"access_token":  accessString,
		"refresh_token": refreshToken,
	})
}

func (h *authHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	req := struct {
		RefreshToken string `json:"refresh_token"`
	}{}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		internalServerError(w, r)
		return
	}

	userID, expires, err := h.refreshStore.Find(req.RefreshToken)
	if err != nil || time.Now().After(expires) {
		unauthorized(w, r)
		return
	}

	_ = h.refreshStore.Delete(req.RefreshToken)

	user, err := h.userService.GetUserByID(userID)
	if err != nil {
		unauthorized(w, r)
		return
	}

	newAccess := jwt.NewWithClaims(jwt.SigningMethodHS256, CustomClaims{
		UserID: user.ID,
		Email:  user.Email,
		Role:   user.Role,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(15 * time.Minute).Unix(),
			Issuer:    "gymbro",
		},
	})

	accessString, _ := newAccess.SignedString(h.key)

	refreshBytes := make([]byte, 32)
	_, _ = rand.Read(refreshBytes)
	newRefresh := hex.EncodeToString(refreshBytes)
	newRefreshExpires := time.Now().Add(7 * 24 * time.Hour)

	if err := h.refreshStore.Save(user.ID, newRefresh, newRefreshExpires); err != nil {
		internalServerError(w, r)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"access_token":  accessString,
		"refresh_token": newRefresh,
	})
}

func (h *authHandler) Logout(w http.ResponseWriter, r *http.Request) {
	req := struct {
		RefreshToken string `json:"refresh_token"`
	}{}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}

	if req.RefreshToken == "" {
		badRequest(w, r)
		return
	}

	if err := h.refreshStore.Delete(req.RefreshToken); err != nil {
		internalServerError(w, r)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]any{
		"ok":      true,
		"message": "token deleted",
	})
}

func NewAuthHandler(db *sqlx.DB, secretKey []byte) *authHandler {
	return &authHandler{
		key:          secretKey,
		userService:  service.NewUserService(db),
		refreshStore: store.NewRefreshStore(db),
	}
}
