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

func NewRefreshStore(db *sqlx.DB) RefreshStore {
	return RefreshStore{db: db}
}

func hashToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}

func (s *RefreshStore) Save(userID int, token string, expires time.Time) error {
	tokenHash := hashToken(token)
	_, err := s.db.Exec(
		`INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)`,
		userID, tokenHash, expires,
	)
	return err
}

func (s *RefreshStore) Find(token string) (int, time.Time, error) {
	var userID int
	var expires time.Time
	tokenHash := hashToken(token)

	err := s.db.QueryRow(`SELECT user_id, expires_at FROM refresh_tokens WHERE token_hash=$1`, tokenHash).Scan(&userID, &expires)
	return userID, expires, err
}

func (s *RefreshStore) Delete(token string) error {
	tokenHash := hashToken(token)
	_, err := s.db.Exec(`DELETE FROM refresh_tokens WHERE token_hash=$1`, tokenHash)
	return err
}
