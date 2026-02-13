-- +goose Up
-- +goose StatementBegin
create extension if not exists pgcrypto;

ALTER TABLE refresh_tokens
ADD COLUMN token_hash text;

UPDATE refresh_tokens
SET token_hash = encode(digest(token, 'sha256'), 'hex');

ALTER TABLE refresh_tokens
ALTER COLUMN token_hash SET NOT NULL;

ALTER TABLE refresh_tokens
DROP COLUMN token;

CREATE UNIQUE INDEX refresh_tokens_token_hash_uq ON refresh_tokens(token_hash);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

ALTER TABLE refresh_tokens
ADD COLUMN token text;

-- восстановить token уже невозможно, поэтому даун миграция условная:
UPDATE refresh_tokens SET token = token_hash;

ALTER TABLE refresh_tokens
ALTER COLUMN token SET NOT NULL;

ALTER TABLE refresh_tokens
DROP COLUMN token_hash;

DROP INDEX IF EXISTS refresh_tokens_token_hash_uq;

-- +goose StatementEnd