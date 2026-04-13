-- +goose Up

ALTER TABLE posts
    ALTER COLUMN workout_id TYPE TEXT
    USING workout_id::text;


-- +goose Down

ALTER TABLE posts
    ALTER COLUMN workout_id TYPE UUID
    USING workout_id::uuid;