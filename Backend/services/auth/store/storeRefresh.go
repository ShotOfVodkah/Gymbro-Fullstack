package store

import (
	"crypto/sha256"
	"encoding/hex"
	"time"

	"github.com/jmoiron/sqlx"
)

type RefreshStore struct {
	db *sqlx.DB
}

type RefreshSession struct {
	ID            int64      `db:"id" json:"id"`
	UserID        int        `db:"user_id" json:"user_id"`
	SessionID     string     `db:"session_id" json:"session_id"`
	TokenHash     string     `db:"token_hash" json:"-"`
	ExpiresAt     time.Time  `db:"expires_at" json:"expires_at"`
	DeviceName    string     `db:"device_name" json:"device_name"`
	Platform      string     `db:"platform" json:"platform"`
	UserAgent     *string    `db:"user_agent" json:"user_agent,omitempty"`
	IPAddress     *string    `db:"ip_address" json:"ip_address,omitempty"`
	CreatedAt     time.Time  `db:"created_at" json:"created_at"`
	LastUsedAt    *time.Time `db:"last_used_at" json:"last_used_at,omitempty"`
	RevokedAt     *time.Time `db:"revoked_at" json:"revoked_at,omitempty"`
	RevokedReason *string    `db:"revoked_reason" json:"revoked_reason,omitempty"`
}

func NewRefreshStore(db *sqlx.DB) RefreshStore {
	return RefreshStore{db: db}
}

func hashToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}

func (s *RefreshStore) Save(userID int, sessionID string, token string, expires time.Time) error {
	tokenHash := hashToken(token)
	_, err := s.db.Exec(
		`INSERT INTO refresh_tokens (user_id, session_id, token_hash, expires_at) VALUES ($1, $2, $3, $4)`,
		userID, sessionID, tokenHash, expires,
	)
	return err
}

func (s *RefreshStore) Find(token string) (int, string, time.Time, error) {
	var userID int
	var sessionID string
	var expires time.Time
	tokenHash := hashToken(token)

	err := s.db.QueryRow(`SELECT user_id, session_id, expires_at FROM refresh_tokens WHERE token_hash=$1`, tokenHash).Scan(&userID, &sessionID, &expires)
	return userID, sessionID, expires, err
}

func (s *RefreshStore) Delete(token string) error {
	tokenHash := hashToken(token)
	_, err := s.db.Exec(`DELETE FROM refresh_tokens WHERE token_hash=$1`, tokenHash)
	return err
}

func (s *RefreshStore) DeleteAllByUserID(userID int) error {
	_, err := s.db.Exec(`DELETE FROM refresh_tokens WHERE user_id = $1`, userID)
	return err
}

func (s *RefreshStore) DeleteBySessionID(sessionID string) error {
	_, err := s.db.Exec(`DELETE FROM refresh_tokens WHERE session_id = $1`, sessionID)
	return err
}

func (rs *RefreshStore) SaveWithMetadata(
	userID int,
	sessionID string,
	token string,
	expiresAt time.Time,
	deviceName string,
	platform string,
	userAgent *string,
	ipAddress *string,
) error {
	tokenHash := hashToken(token)

	_, err := rs.db.Exec(`
		INSERT INTO refresh_tokens (
			user_id,
			session_id,
			token_hash,
			expires_at,
			device_name,
			platform,
			user_agent,
			ip_address,
			last_used_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
	`, userID, sessionID, tokenHash, expiresAt, deviceName, platform, userAgent, ipAddress)

	return err
}

func (rs *RefreshStore) FindActive(token string) (userID int, sessionID string, expires time.Time, err error) {
	tokenHash := hashToken(token)

	err = rs.db.QueryRow(`
		SELECT user_id, session_id, expires_at
		FROM refresh_tokens
		WHERE token_hash = $1
		  AND revoked_at IS NULL
	`, tokenHash).Scan(&userID, &sessionID, &expires)

	if err != nil {
		return 0, "", time.Time{}, err
	}

	_, _ = rs.db.Exec(`
		UPDATE refresh_tokens
		SET last_used_at = NOW()
		WHERE token_hash = $1
	`, tokenHash)

	return userID, sessionID, expires, nil
}

func (rs *RefreshStore) RevokeByToken(token string, reason string) error {
	tokenHash := hashToken(token)

	_, err := rs.db.Exec(`
		UPDATE refresh_tokens
		SET revoked_at = NOW(),
		    revoked_reason = $2
		WHERE token_hash = $1
		  AND revoked_at IS NULL
	`, tokenHash, reason)

	return err
}

func (rs *RefreshStore) RevokeBySessionID(userID int, sessionID string, reason string) error {
	_, err := rs.db.Exec(`
		UPDATE refresh_tokens
		SET revoked_at = NOW(),
		    revoked_reason = $3
		WHERE user_id = $1
		  AND session_id = $2
		  AND revoked_at IS NULL
	`, userID, sessionID, reason)

	return err
}

func (rs *RefreshStore) RevokeAllByUserID(userID int, reason string) error {
	_, err := rs.db.Exec(`
		UPDATE refresh_tokens
		SET revoked_at = NOW(),
		    revoked_reason = $2
		WHERE user_id = $1
		  AND revoked_at IS NULL
	`, userID, reason)

	return err
}

func (rs *RefreshStore) ListActiveByUserID(userID int) ([]RefreshSession, error) {
	var sessions []RefreshSession

	err := rs.db.Select(&sessions, `
		SELECT id, user_id, session_id, token_hash, expires_at,
		       device_name, platform, user_agent, ip_address,
		       created_at, last_used_at, revoked_at, revoked_reason
		FROM refresh_tokens
		WHERE user_id = $1
		  AND revoked_at IS NULL
		  AND expires_at > NOW()
		ORDER BY last_used_at DESC NULLS LAST, created_at DESC
	`, userID)

	return sessions, err
}