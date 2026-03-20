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
	err := us.db.Get(&result, `select * from users where email = $1`, email)
	if err != nil {
		return nil, fmt.Errorf("GetUserByEmail: %w", err)
	}
	return &result, nil
}

func (us *UserStore) InsertUser(user *types.User) (*types.User, error) {
	var result types.User
	err := us.db.Get(&result, `insert into users (email, password_hash, role) values ($1, $2, $3) returning *`, user.Email, user.PasswordHash, user.Role)
	if err != nil {
		return nil, fmt.Errorf("InsertUser: %w", err)
	}
	return &result, nil
}

func (us *UserStore) ListUsers() ([]types.User, error) {
	var users []types.User
	err := us.db.Select(&users, `select id, email, role from users`)
	if err != nil {
		return nil, err
	}
	return users, nil
}

func (us *UserStore) GetUserByID(id int) (*types.User, error) {
	var user types.User
	err := us.db.Get(&user, `select id, email, role from users where id = $1`, id)
	if err != nil {
		return nil, err
	}
	return &user, nil
}
