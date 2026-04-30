-- +goose Up
-- +goose StatementBegin

ALTER TABLE challenges
ADD COLUMN IF NOT EXISTS target_filter TEXT;

CREATE INDEX IF NOT EXISTS idx_challenges_target_filter
    ON challenges(target_filter);

-- +goose StatementEnd


-- +goose Down
-- +goose StatementBegin

DROP INDEX IF EXISTS idx_challenges_target_filter;

ALTER TABLE challenges
DROP COLUMN IF EXISTS target_filter;

-- +goose StatementEnd