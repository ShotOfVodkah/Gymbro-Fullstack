-- +goose Up
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY,
    author_id UUID NOT NULL,
    community_id UUID NULL REFERENCES communities(id) ON DELETE SET NULL,
    workout_id UUID NULL,
    kind TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    location TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_posts_author_id ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_community_id ON posts(community_id);
CREATE INDEX IF NOT EXISTS idx_posts_workout_id ON posts(workout_id);
CREATE INDEX IF NOT EXISTS idx_posts_kind ON posts(kind);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);

-- +goose Down
DROP TABLE IF EXISTS posts;