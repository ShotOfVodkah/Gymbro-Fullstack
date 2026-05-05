-- +goose Up
ALTER TABLE refresh_tokens
DROP CONSTRAINT IF EXISTS refresh_tokens_session_id_uq;

DROP INDEX IF EXISTS refresh_tokens_session_id_uq;

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_session_id
ON refresh_tokens(session_id);

-- +goose Down
DROP INDEX IF EXISTS idx_refresh_tokens_session_id;

ALTER TABLE refresh_tokens
ADD CONSTRAINT refresh_tokens_session_id_uq UNIQUE (session_id);