-- +goose Up
-- +goose StatementBegin

ALTER TABLE community_messages
ADD COLUMN IF NOT EXISTS challenge_id TEXT;

CREATE INDEX IF NOT EXISTS idx_community_messages_challenge_id
    ON community_messages(challenge_id);

-- +goose StatementEnd


-- +goose Down
-- +goose StatementBegin

DROP INDEX IF EXISTS idx_community_messages_challenge_id;

ALTER TABLE community_messages
DROP COLUMN IF EXISTS challenge_id;

-- +goose StatementEnd