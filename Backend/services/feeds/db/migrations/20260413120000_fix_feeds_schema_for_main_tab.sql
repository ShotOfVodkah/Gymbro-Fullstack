-- +goose Up
BEGIN;

ALTER TABLE communities
    ADD COLUMN IF NOT EXISTS description TEXT;

ALTER TABLE communities
    ADD COLUMN IF NOT EXISTS created_by INT;

ALTER TABLE communities
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

UPDATE communities
SET updated_at = created_at
WHERE updated_at IS NULL;

UPDATE communities
SET created_by = 0
WHERE created_by IS NULL;

ALTER TABLE communities
    ALTER COLUMN created_by SET DEFAULT 0;

ALTER TABLE communities
    ALTER COLUMN created_by SET NOT NULL;

ALTER TABLE posts
    ADD COLUMN IF NOT EXISTS session_id TEXT;

ALTER TABLE posts
    DROP COLUMN IF EXISTS workout_id;

ALTER TABLE community_messages
    ADD COLUMN IF NOT EXISTS session_id TEXT;

ALTER TABLE community_messages
    DROP COLUMN IF EXISTS workout_id;

CREATE INDEX IF NOT EXISTS idx_posts_session_id
    ON posts(session_id);

CREATE INDEX IF NOT EXISTS idx_post_comments_created_at
    ON post_comments(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_post_reactions_post_user
    ON post_reactions(post_id, user_id);

CREATE INDEX IF NOT EXISTS idx_community_messages_session_id
    ON community_messages(session_id);

COMMIT;

-- +goose Down
BEGIN;

DROP INDEX IF EXISTS idx_community_messages_session_id;
DROP INDEX IF EXISTS idx_post_reactions_post_user;
DROP INDEX IF EXISTS idx_post_comments_created_at;
DROP INDEX IF EXISTS idx_posts_session_id;

ALTER TABLE communities
    ALTER COLUMN created_by DROP NOT NULL;

ALTER TABLE communities
    ALTER COLUMN created_by DROP DEFAULT;

COMMIT;