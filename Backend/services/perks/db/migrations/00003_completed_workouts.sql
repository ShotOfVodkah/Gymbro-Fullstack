-- +goose Up

ALTER TABLE user_perks
ADD COLUMN IF NOT EXISTS completed_workouts INT NOT NULL DEFAULT 0;

-- +goose Down

ALTER TABLE user_perks
DROP COLUMN IF EXISTS completed_workouts;