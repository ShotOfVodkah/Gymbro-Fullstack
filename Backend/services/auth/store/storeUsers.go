package store

import (
    "fmt"

    "github.com/alexandra-gritsaenko/gymbro-auth/types"
    "github.com/jmoiron/sqlx"
)

type UserStore struct {
    db *sqlx.DB
}

func NewUserStore(db *sqlx.DB) UserStore {
    return UserStore{db: db}
}

func (us *UserStore) GetUserByEmail(email string) (*types.User, error) {
    var result types.User

    err := us.db.Get(&result, `
        SELECT id, email, password_hash, role, email_verified, inserted_at, updated_at
        FROM users
        WHERE email = $1
    `, email)

    if err != nil {
        return nil, fmt.Errorf("GetUserByEmail: %w", err)
    }

    return &result, nil
}

func (us *UserStore) InsertUser(user *types.User) (*types.User, error) {
    var result types.User

    err := us.db.Get(&result, `
        INSERT INTO users (email, password_hash, role, email_verified)
        VALUES ($1, $2, $3, FALSE)
        RETURNING id, email, password_hash, role, email_verified, inserted_at, updated_at
    `, user.Email, user.PasswordHash, user.Role)

    if err != nil {
        return nil, fmt.Errorf("InsertUser: %w", err)
    }

    return &result, nil
}

func (us *UserStore) ListUsers() ([]types.User, error) {
    var users []types.User

    err := us.db.Select(&users, `
        SELECT id, email, role, email_verified, inserted_at, updated_at
        FROM users
    `)

    if err != nil {
        return nil, err
    }

    return users, nil
}

func (us *UserStore) GetUserByID(id int) (*types.User, error) {
    var user types.User

    err := us.db.Get(&user, `
        SELECT id, email, password_hash, role, email_verified, inserted_at, updated_at
        FROM users
        WHERE id = $1
    `, id)

    if err != nil {
        return nil, err
    }

    return &user, nil
}

func (us *UserStore) MarkEmailVerified(userID int) error {
    _, err := us.db.Exec(`
        UPDATE users
        SET email_verified = TRUE,
            updated_at = NOW()
        WHERE id = $1
    `, userID)

    if err != nil {
        return fmt.Errorf("MarkEmailVerified: %w", err)
    }

    return nil
}