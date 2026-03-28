-- +goose Up
CREATE TABLE workouts (
    id        TEXT PRIMARY KEY,
    user_id   TEXT NOT NULL,
    name      TEXT NOT NULL,
    type      TEXT NOT NULL,
    exercises JSONB NOT NULL DEFAULT '[]'
);

-- +goose Down
DROP TABLE workouts;
