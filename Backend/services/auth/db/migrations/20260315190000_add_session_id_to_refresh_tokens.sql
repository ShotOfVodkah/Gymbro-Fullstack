-- +goose Up
-- +goose StatementBegin

ALTER TABLE refresh_tokens
ADD COLUMN session_id text;

UPDATE refresh_tokens
SET session_id = encode(gen_random_bytes(16), 'hex')
WHERE session_id IS NULL;

ALTER TABLE refresh_tokens
ALTER COLUMN session_id SET NOT NULL;

CREATE UNIQUE INDEX refresh_tokens_session_id_uq ON refresh_tokens(session_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP INDEX IF EXISTS refresh_tokens_session_id_uq;

ALTER TABLE refresh_tokens
DROP COLUMN session_id;

-- +goose StatementEnd