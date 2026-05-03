package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"time"
	"fmt"
	"net/url"
	"log"

	"github.com/alexandra-gritsaenko/gymbro-auth/service"
	"github.com/alexandra-gritsaenko/gymbro-auth/store"
	"github.com/alexandra-gritsaenko/gymbro-auth/types"
	"github.com/alexandra-gritsaenko/gymbro-authmw"
	"github.com/alexedwards/argon2id"
	"github.com/dgrijalva/jwt-go"
	"github.com/jmoiron/sqlx"
)

type authHandler struct {
	key          []byte

	userService  service.UserService
	refreshStore store.RefreshStore

	verificationStore store.EmailVerificationStore
	emailSender       service.EmailSender
	verifyEmailURL    string

	appEnv string
}

type createUserRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	Role     string `json:"role"`
}

type loginRequest struct {
	User     string `json:"user"`
	Password string `json:"password"`
}

type verifyEmailRequest struct {
    Token string `json:"token"`
}

type resendVerificationRequest struct {
    Email string `json:"email"`
}

type tokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

func (h *authHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")

	switch {
	case r.Method == http.MethodPost && r.URL.Path == "/auth/register":
		h.CreateUser(w, r)
	case r.Method == http.MethodPost && r.URL.Path == "/auth/login":
		h.Token(w, r)
	case r.Method == http.MethodPost && r.URL.Path == "/auth/refresh":
		h.Refresh(w, r)
	case r.Method == http.MethodPost && r.URL.Path == "/auth/verify-email":
		h.VerifyEmail(w, r)
	case r.Method == http.MethodPost && r.URL.Path == "/auth/resend-verification-email":
    	h.ResendVerificationEmail(w, r)
	case r.Method == http.MethodGet && r.URL.Path == "/auth/verify-email-link":
		h.VerifyEmailLink(w, r)
	default:
		notFound(w, r)
	}
}

func NewAuthHandler(db *sqlx.DB, secretKey []byte, emailSender service.EmailSender, verifyEmailURL string, appEnv string,) *authHandler {
	return &authHandler{
		key:          secretKey,
		userService:  service.NewUserService(db),
		refreshStore: store.NewRefreshStore(db),
		verificationStore: store.NewEmailVerificationStore(db),
        emailSender:       emailSender,
        verifyEmailURL:    verifyEmailURL,
		appEnv: appEnv,
	}
}

func (h *authHandler) CreateUser(w http.ResponseWriter, r *http.Request) {
	var req createUserRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}

	if req.Email == "" || req.Password == "" || req.Role == "" {
		badRequest(w, r)
		return
	}

	if !isValidRole(req.Role) {
		badRequest(w, r)
		return
	}

	hash, err := argon2id.CreateHash(req.Password, argon2id.DefaultParams)
	if err != nil {
		internalServerError(w, r)
		return
	}

	user := &types.User{
		Email:        req.Email,
		PasswordHash: &hash,
		Role:         req.Role,
	}

	created, err := h.userService.CreateUser(user)
	if err != nil {
		internalServerError(w, r)
		return
	}

	rawToken, err := generateSecureToken()
	if err != nil {
		internalServerError(w, r)
		return
	}

	tokenHash := hashToken(rawToken)
	expiresAt := time.Now().Add(24 * time.Hour)

	if err := h.verificationStore.Save(created.ID, tokenHash, expiresAt); err != nil {
		internalServerError(w, r)
		return
	}

	verificationURL := fmt.Sprintf(
		"%s?token=%s",
		h.verifyEmailURL,
		url.QueryEscape(rawToken),
	)

	if err := h.emailSender.SendVerificationEmail(created.Email, verificationURL); err != nil {
		log.Printf("send verification email failed: %v", err)

		if h.appEnv != "dev" {
			internalServerError(w, r)
			return
		}
	}

	response := map[string]any{
		"id":             created.ID,
		"email":          created.Email,
		"role":           created.Role,
		"email_verified": created.EmailVerified,
	}

	if h.appEnv == "dev" {
		response["dev_verify_url"] = verificationURL
	}

	json.NewEncoder(w).Encode(response)
}

func isValidRole(role string) bool {
	switch role {
	case "athlete", "coach", "admin":
		return true
	default:
		return false
	}
}

func (h *authHandler) Token(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		internalServerError(w, r)
		return
	}

	user, err := h.userService.AuthenticateUserByEmailPassword(req.User, req.Password)
	if err != nil {
		unauthorized(w, r)
		return
	}

	if !user.EmailVerified {
		w.WriteHeader(http.StatusForbidden)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "email is not verified",
		})
		return
	}

	sessionBytes := make([]byte, 16)
	rand.Read(sessionBytes)
	sessionID := hex.EncodeToString(sessionBytes)

	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, authmw.Claims{
		UserID:    user.ID,
		Email:     user.Email,
		Role:      user.Role,
		SessionID: sessionID,
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

	err = h.refreshStore.Save(user.ID, sessionID, refreshToken, refreshExpires)
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

	userID, sessionID, expires, err := h.refreshStore.Find(req.RefreshToken)
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

	newAccess := jwt.NewWithClaims(jwt.SigningMethodHS256, authmw.Claims{
		UserID:    user.ID,
		Email:     user.Email,
		Role:      user.Role,
		SessionID: sessionID,
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

	if err := h.refreshStore.Save(user.ID, sessionID, newRefresh, newRefreshExpires); err != nil {
		internalServerError(w, r)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"access_token":  accessString,
		"refresh_token": newRefresh,
	})
}

func (h *authHandler) Logout(w http.ResponseWriter, r *http.Request) {
	claims, ok := authmw.GetClaims(r.Context())
	if !ok || claims.SessionID == "" {
		unauthorized(w, r)
		return
	}

	sessionID := claims.SessionID

	if err := h.refreshStore.DeleteBySessionID(sessionID); err != nil {
		internalServerError(w, r)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]any{
		"ok":      true,
		"message": "session deleted",
	})
}

func (h *authHandler) VerifyEmail(w http.ResponseWriter, r *http.Request) {
	var req verifyEmailRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		badRequest(w, r)
		return
	}

	if req.Token == "" {
		badRequest(w, r)
		return
	}

	tokenHash := hashToken(req.Token)

	verificationToken, err := h.verificationStore.FindValid(tokenHash)
	if err != nil {
		internalServerError(w, r)
		return
	}

	if verificationToken == nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "invalid or expired verification token",
		})
		return
	}

	if err := h.userService.MarkEmailVerified(verificationToken.UserID); err != nil {
		internalServerError(w, r)
		return
	}

	if err := h.verificationStore.MarkUsed(verificationToken.ID); err != nil {
		internalServerError(w, r)
		return
	}

	user, err := h.userService.GetUserByID(verificationToken.UserID)
	if err != nil {
		internalServerError(w, r)
		return
	}

	tokens, err := h.issueTokensForUser(user)
	if err != nil {
		internalServerError(w, r)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(tokens)
}

func (h *authHandler) ResendVerificationEmail(w http.ResponseWriter, r *http.Request) {
    var req resendVerificationRequest

    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        badRequest(w, r)
        return
    }

    if req.Email == "" {
        badRequest(w, r)
        return
    }

    user, err := h.userService.GetUserByEmail(req.Email)
    if err != nil || user == nil {
        json.NewEncoder(w).Encode(map[string]any{
            "ok":      true,
            "message": "if account exists, verification email was sent",
        })
        return
    }

    if user.EmailVerified {
        json.NewEncoder(w).Encode(map[string]any{
            "ok":      true,
            "message": "email already verified",
        })
        return
    }

    _ = h.verificationStore.DeleteUnusedByUserID(user.ID)

    rawToken, err := generateSecureToken()
    if err != nil {
        internalServerError(w, r)
        return
    }

    tokenHash := hashToken(rawToken)
    expiresAt := time.Now().Add(24 * time.Hour)

    if err := h.verificationStore.Save(user.ID, tokenHash, expiresAt); err != nil {
        internalServerError(w, r)
        return
    }

    verificationURL := fmt.Sprintf(
        "%s?token=%s",
        h.verifyEmailURL,
        url.QueryEscape(rawToken),
    )

    if err := h.emailSender.SendVerificationEmail(user.Email, verificationURL); err != nil {
        internalServerError(w, r)
        return
    }

    json.NewEncoder(w).Encode(map[string]any{
        "ok":      true,
        "message": "if account exists, verification email was sent",
    })
}

func (h *authHandler) issueTokensForUser(user *types.User) (*tokenResponse, error) {
	sessionID, err := generateSessionID()
	if err != nil {
		return nil, err
	}

	accessToken, err := h.createAccessToken(user, sessionID)
	if err != nil {
		return nil, err
	}

	refreshToken, err := generateSecureToken()
	if err != nil {
		return nil, err
	}

	refreshExpiresAt := time.Now().Add(7 * 24 * time.Hour)

	if err := h.refreshStore.Save(user.ID, sessionID, refreshToken, refreshExpiresAt); err != nil {
		return nil, err
	}

	return &tokenResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

func generateSessionID() (string, error) {
	sessionBytes := make([]byte, 16)
	if _, err := rand.Read(sessionBytes); err != nil {
		return "", err
	}

	return hex.EncodeToString(sessionBytes), nil
}

func (h *authHandler) createAccessToken(user *types.User, sessionID string) (string, error) {
	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, authmw.Claims{
		UserID:    user.ID,
		Email:     user.Email,
		Role:      user.Role,
		SessionID: sessionID,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(15 * time.Minute).Unix(),
			Issuer:    "gymbro",
		},
	})

	return accessToken.SignedString(h.key)
}

func (h *authHandler) VerifyEmailLink(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		badRequest(w, r)
		return
	}

	appURL := fmt.Sprintf(
		"gymbro://verify-email?token=%s",
		url.QueryEscape(token),
	)

	http.Redirect(w, r, appURL, http.StatusFound)
}