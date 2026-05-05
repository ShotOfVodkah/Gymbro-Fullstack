-- +goose Up
-- +goose StatementBegin

ALTER TABLE refresh_tokens
ADD COLUMN IF NOT EXISTS device_name TEXT NOT NULL DEFAULT 'Unknown device',
ADD COLUMN IF NOT EXISTS platform TEXT NOT NULL DEFAULT 'unknown',
ADD COLUMN IF NOT EXISTS user_agent TEXT,
ADD COLUMN IF NOT EXISTS ip_address TEXT,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS last_used_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS revoked_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS revoked_reason TEXT;

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id
ON refresh_tokens(user_id);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_session_id
ON refresh_tokens(session_id);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_active_user_id
ON refresh_tokens(user_id)
WHERE revoked_at IS NULL;

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP INDEX IF EXISTS idx_refresh_tokens_active_user_id;
DROP INDEX IF EXISTS idx_refresh_tokens_session_id;
DROP INDEX IF EXISTS idx_refresh_tokens_user_id;

ALTER TABLE refresh_tokens
DROP COLUMN IF EXISTS revoked_reason,
DROP COLUMN IF EXISTS revoked_at,
DROP COLUMN IF EXISTS last_used_at,
DROP COLUMN IF EXISTS created_at,
DROP COLUMN IF EXISTS ip_address,
DROP COLUMN IF EXISTS user_agent,
DROP COLUMN IF EXISTS platform,
DROP COLUMN IF EXISTS device_name;

-- +goose StatementEnd