-- +goose Up

CREATE TABLE IF NOT EXISTS community_message_reactions (
    id UUID PRIMARY KEY,
    message_id UUID NOT NULL REFERENCES community_messages(id) ON DELETE CASCADE,
    user_id INT NOT NULL,
    emoji TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_message_reaction UNIQUE (message_id, user_id, emoji)
);

CREATE INDEX IF NOT EXISTS idx_community_message_reactions_message_id
    ON community_message_reactions(message_id);

CREATE INDEX IF NOT EXISTS idx_community_message_reactions_user_id
    ON community_message_reactions(user_id);

-- +goose Down

DROP TABLE IF EXISTS community_message_reactions;