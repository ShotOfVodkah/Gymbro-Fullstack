package store

import (
	"database/sql"
	"errors"
	"fmt"

	"github.com/alexandra-gritsaenko/gymbro-profile/types"
	"github.com/jmoiron/sqlx"
)

var ErrNotFound = errors.New("not found")

type ProfileStore struct {
	db *sqlx.DB
}

func NewProfileStore(db *sqlx.DB) ProfileStore {
	return ProfileStore{db: db}
}

func (ps *ProfileStore) GetByUserID(userID int) (*types.Profile, error) {
	var profile types.Profile
	err := ps.db.Get(&profile, `
		SELECT user_id, name, username, status, subtitle, avatar_system_name, badge, workouts_this_month
		FROM profiles
		WHERE user_id = $1
	`, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("GetByUserID: %w", err)
	}
	return &profile, nil
}

func (ps *ProfileStore) ListByUserIDs(ids []int) ([]types.Profile, error) {
	query, args, err := sqlx.In(`
		SELECT user_id, name, username, status, subtitle, avatar_system_name, badge, workouts_this_month
		FROM profiles
		WHERE user_id IN (?)
		ORDER BY user_id
	`, ids)
	if err != nil {
		return nil, fmt.Errorf("ListByUserIDs build query: %w", err)
	}
	query = ps.db.Rebind(query)

	var profiles []types.Profile
	if err := ps.db.Select(&profiles, query, args...); err != nil {
		return nil, fmt.Errorf("ListByUserIDs: %w", err)
	}
	return profiles, nil
}