package store

import (
	"fmt"

	"github.com/alexandra-gritsaenko/gymbro-workouts/types"
	"github.com/jmoiron/sqlx"
)

type ExerciseStore struct {
	db *sqlx.DB
}

func NewExerciseStore(db *sqlx.DB) ExerciseStore {
	return ExerciseStore{db: db}
}

func (es *ExerciseStore) ListByType(exerciseType string) ([]types.CatalogExercise, error) {
	var exercises []types.CatalogExercise
	err := es.db.Select(&exercises,
		`SELECT id, name, type, muscle_group FROM exercises WHERE type = $1 ORDER BY name`,
		exerciseType,
	)
	if err != nil {
		return nil, fmt.Errorf("ListByType: %w", err)
	}
	return exercises, nil
}

func (es *ExerciseStore) ListAll() ([]types.CatalogExercise, error) {
	var exercises []types.CatalogExercise
	err := es.db.Select(&exercises,
		`SELECT id, name, type, muscle_group FROM exercises ORDER BY type, name`,
	)
	if err != nil {
		return nil, fmt.Errorf("ListAll: %w", err)
	}
	return exercises, nil
}
