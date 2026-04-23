-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_invalid_events (
    id BIGSERIAL PRIMARY KEY,
    batch_id TEXT,
    user_id BIGINT NOT NULL,
    request_id TEXT,
    event_index INT NOT NULL,
    event_name TEXT,
    reason TEXT NOT NULL,
    payload JSONB NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_invalid_events_batch_id
    ON analytics_invalid_events(batch_id);

CREATE INDEX IF NOT EXISTS idx_analytics_invalid_events_user_id
    ON analytics_invalid_events(user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_invalid_events_event_name
    ON analytics_invalid_events(event_name);

CREATE INDEX IF NOT EXISTS idx_analytics_invalid_events_received_at
    ON analytics_invalid_events(received_at);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_invalid_events_received_at;
DROP INDEX IF EXISTS idx_analytics_invalid_events_event_name;
DROP INDEX IF EXISTS idx_analytics_invalid_events_user_id;
DROP INDEX IF EXISTS idx_analytics_invalid_events_batch_id;

DROP TABLE IF EXISTS analytics_invalid_events;