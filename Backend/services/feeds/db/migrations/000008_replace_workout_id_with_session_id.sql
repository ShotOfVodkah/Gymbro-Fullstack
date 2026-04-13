-- +goose Up

ALTER TABLE posts
    ADD COLUMN session_id TEXT;

UPDATE posts
SET session_id = NULL;

ALTER TABLE posts
    DROP COLUMN workout_id;


-- +goose Down

ALTER TABLE posts
    ADD COLUMN workout_id TEXT;

UPDATE posts
SET workout_id = NULL;

ALTER TABLE posts
    DROP COLUMN session_id;