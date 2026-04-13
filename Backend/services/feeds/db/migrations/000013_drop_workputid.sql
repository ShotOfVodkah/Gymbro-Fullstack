-- +goose Up

ALTER TABLE community_messages
DROP COLUMN IF EXISTS workout_id;

-- +goose Down

ALTER TABLE community_messages
ADD COLUMN workout_id TEXT;