-- +goose Up
-- +goose StatementBegin

ALTER TABLE users
ADD COLUMN IF NOT EXISTS role varchar(20) NOT NULL DEFAULT 'user';

CREATE TABLE refresh_tokens (
  id bigserial PRIMARY KEY,
  user_id bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token text NOT NULL UNIQUE,
  expires_at timestamp(0) NOT NULL,
  created_at timestamp(0) NOT NULL DEFAULT (now() at time zone 'utc')
);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE refresh_tokens;
ALTER TABLE users DROP COLUMN role;
-- +goose StatementEnd