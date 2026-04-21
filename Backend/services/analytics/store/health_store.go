package store

import "github.com/jmoiron/sqlx"

type HealthStore struct {
	db *sqlx.DB
}

func NewHealthStore(db *sqlx.DB) *HealthStore {
	return &HealthStore{
		db: db,
	}
}

func (s *HealthStore) Ping() error {
	return s.db.Ping()
}