-- +goose Up

CREATE TABLE IF NOT EXISTS chat_room_reads (
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,
    last_read_message_id UUID REFERENCES community_messages(id) ON DELETE SET NULL,
    last_read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (community_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_room_reads_user
    ON chat_room_reads(user_id);

CREATE INDEX IF NOT EXISTS idx_chat_room_reads_community
    ON chat_room_reads(community_id);

CREATE INDEX IF NOT EXISTS idx_community_messages_community_created
    ON community_messages(community_id, created_at DESC);

-- +goose Down

DROP INDEX IF EXISTS idx_community_messages_community_created;
DROP INDEX IF EXISTS idx_chat_room_reads_community;
DROP INDEX IF EXISTS idx_chat_room_reads_user;
DROP TABLE IF EXISTS chat_room_reads;