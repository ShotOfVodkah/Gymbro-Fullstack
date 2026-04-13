-- +goose Up
CREATE TABLE IF NOT EXISTS communities (
    id UUID PRIMARY KEY,
    title TEXT NOT NULL,
    kind TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_communities_kind ON communities(kind);

-- +goose Down
DROP TABLE IF EXISTS communities;