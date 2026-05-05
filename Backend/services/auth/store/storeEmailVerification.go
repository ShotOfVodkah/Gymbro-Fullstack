package store

import (
    "database/sql"
    "fmt"
    "time"

    "github.com/jmoiron/sqlx"
)

type EmailVerificationToken struct {
    ID        int64      `db:"id"`
    UserID    int       `db:"user_id"`
    TokenHash string     `db:"token_hash"`
    ExpiresAt time.Time  `db:"expires_at"`
    UsedAt    *time.Time `db:"used_at"`
    CreatedAt time.Time  `db:"created_at"`
}

type EmailVerificationStore struct {
    db *sqlx.DB
}

func NewEmailVerificationStore(db *sqlx.DB) EmailVerificationStore {
    return EmailVerificationStore{db: db}
}

func (s *EmailVerificationStore) Save(userID int, tokenHash string, expiresAt time.Time) error {
    _, err := s.db.Exec(`
        INSERT INTO email_verification_tokens (user_id, token_hash, expires_at)
        VALUES ($1, $2, $3)
    `, userID, tokenHash, expiresAt)

    if err != nil {
        return fmt.Errorf("SaveEmailVerificationToken: %w", err)
    }

    return nil
}

func (s *EmailVerificationStore) FindValid(tokenHash string) (*EmailVerificationToken, error) {
    var token EmailVerificationToken

    err := s.db.Get(&token, `
        SELECT id, user_id, token_hash, expires_at, used_at, created_at
        FROM email_verification_tokens
        WHERE token_hash = $1
          AND used_at IS NULL
          AND expires_at > NOW()
        LIMIT 1
    `, tokenHash)

    if err == sql.ErrNoRows {
        return nil, nil
    }

    if err != nil {
        return nil, fmt.Errorf("FindValidEmailVerificationToken: %w", err)
    }

    return &token, nil
}

func (s *EmailVerificationStore) MarkUsed(id int64) error {
    _, err := s.db.Exec(`
        UPDATE email_verification_tokens
        SET used_at = NOW()
        WHERE id = $1
    `, id)

    if err != nil {
        return fmt.Errorf("MarkEmailVerificationTokenUsed: %w", err)
    }

    return nil
}

func (s *EmailVerificationStore) DeleteUnusedByUserID(userID int) error {
    _, err := s.db.Exec(`
        DELETE FROM email_verification_tokens
        WHERE user_id = $1
          AND used_at IS NULL
    `, userID)

    if err != nil {
        return fmt.Errorf("DeleteUnusedEmailVerificationTokensByUserID: %w", err)
    }

    return nil
}