-- +goose Up

ALTER TABLE communities
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS created_by INT,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

UPDATE communities
SET updated_at = created_at
WHERE updated_at IS NULL;

-- +goose Down

ALTER TABLE communities
    DROP COLUMN IF EXISTS description,
    DROP COLUMN IF EXISTS created_by,
    DROP COLUMN IF EXISTS updated_at;