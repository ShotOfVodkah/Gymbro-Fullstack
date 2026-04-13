-- +goose Up

CREATE TABLE IF NOT EXISTS community_messages (
    id UUID PRIMARY KEY,
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    sender_id INT NOT NULL,
    kind TEXT NOT NULL,
    text TEXT,
    workout_id TEXT,
    session_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_community_messages_community_id
    ON community_messages(community_id);

CREATE INDEX IF NOT EXISTS idx_community_messages_created_at
    ON community_messages(created_at DESC);

-- +goose Down

DROP TABLE IF EXISTS community_messages;