-- +goose Up

ALTER TABLE user_perks
ADD COLUMN IF NOT EXISTS last_freeze_grant_month TEXT;

-- +goose Down

ALTER TABLE user_perks
DROP COLUMN IF EXISTS last_freeze_grant_month;