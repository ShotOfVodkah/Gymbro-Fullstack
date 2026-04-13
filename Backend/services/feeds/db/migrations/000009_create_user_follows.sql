-- +goose Up

CREATE TABLE IF NOT EXISTS user_follows (
    id UUID PRIMARY KEY,
    follower_id INT NOT NULL,
    followee_id INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_follow UNIQUE (follower_id, followee_id)
);

CREATE INDEX IF NOT EXISTS idx_user_follows_follower_id ON user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_followee_id ON user_follows(followee_id);

-- +goose Down

DROP TABLE IF EXISTS user_follows;