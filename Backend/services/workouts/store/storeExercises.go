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

func (es *ExerciseStore) ListByType(exerciseType string, locale string) ([]types.CatalogExercise, error) {
	nameExpr := exerciseDisplayNameExpr("e", locale)
	var exercises []types.CatalogExercise
	query := `SELECT id, ` + nameExpr + ` AS name, type, muscle_group FROM exercises e WHERE type = $1 ORDER BY ` + nameExpr
	err := es.db.Select(&exercises, query, exerciseType)
	if err != nil {
		return nil, fmt.Errorf("ListByType: %w", err)
	}
	return exercises, nil
}

func (es *ExerciseStore) ListAll(locale string) ([]types.CatalogExercise, error) {
	nameExpr := exerciseDisplayNameExpr("e", locale)
	var exercises []types.CatalogExercise
	query := `SELECT id, ` + nameExpr + ` AS name, type, muscle_group FROM exercises e ORDER BY type, ` + nameExpr
	err := es.db.Select(&exercises, query)
	if err != nil {
		return nil, fmt.Errorf("ListAll: %w", err)
	}
	return exercises, nil
}
