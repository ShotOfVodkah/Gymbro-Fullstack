-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_event_batches (
    id BIGSERIAL PRIMARY KEY,
    batch_id TEXT NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    events_count INT NOT NULL DEFAULT 0,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'received',
    source TEXT NOT NULL DEFAULT 'ios',
    app_version TEXT,
    platform TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS analytics_events_raw (
    id BIGSERIAL PRIMARY KEY,
    batch_id TEXT NOT NULL REFERENCES analytics_event_batches(batch_id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,
    event_index INT NOT NULL,
    payload JSONB NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS analytics_events (
    id BIGSERIAL PRIMARY KEY,
    batch_id TEXT NOT NULL REFERENCES analytics_event_batches(batch_id) ON DELETE CASCADE,
    raw_event_id BIGINT REFERENCES analytics_events_raw(id) ON DELETE SET NULL,

    user_id BIGINT NOT NULL,
    session_id TEXT NOT NULL,

    event_name TEXT NOT NULL,
    event_date DATE NOT NULL,
    event_time TIMESTAMPTZ NOT NULL,
    server_received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    screen TEXT,
    platform TEXT NOT NULL,
    app_version TEXT NOT NULL,

    event_category TEXT,
    entity_type TEXT,
    entity_id TEXT,

    properties JSONB NOT NULL DEFAULT '{}'::jsonb,
    processing_status TEXT NOT NULL DEFAULT 'pending',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_date
    ON analytics_events(event_date);

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_name
    ON analytics_events(event_name);

CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id
    ON analytics_events(user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_session_id
    ON analytics_events(session_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_screen
    ON analytics_events(screen);

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_name_event_date
    ON analytics_events(event_name, event_date);

CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id_event_time
    ON analytics_events(user_id, event_time);

CREATE INDEX IF NOT EXISTS idx_analytics_events_session_id_event_time
    ON analytics_events(session_id, event_time);

CREATE INDEX IF NOT EXISTS idx_analytics_events_processing_status
    ON analytics_events(processing_status);

CREATE INDEX IF NOT EXISTS idx_analytics_events_raw_batch_id
    ON analytics_events_raw(batch_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_raw_user_id
    ON analytics_events_raw(user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_event_batches_user_id
    ON analytics_event_batches(user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_event_batches_received_at
    ON analytics_event_batches(received_at);

CREATE INDEX IF NOT EXISTS idx_analytics_events_properties_gin
    ON analytics_events
    USING GIN (properties);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_events_properties_gin;
DROP INDEX IF EXISTS idx_analytics_event_batches_received_at;
DROP INDEX IF EXISTS idx_analytics_event_batches_user_id;
DROP INDEX IF EXISTS idx_analytics_events_raw_user_id;
DROP INDEX IF EXISTS idx_analytics_events_raw_batch_id;
DROP INDEX IF EXISTS idx_analytics_events_processing_status;
DROP INDEX IF EXISTS idx_analytics_events_session_id_event_time;
DROP INDEX IF EXISTS idx_analytics_events_user_id_event_time;
DROP INDEX IF EXISTS idx_analytics_events_event_name_event_date;
DROP INDEX IF EXISTS idx_analytics_events_screen;
DROP INDEX IF EXISTS idx_analytics_events_session_id;
DROP INDEX IF EXISTS idx_analytics_events_user_id;
DROP INDEX IF EXISTS idx_analytics_events_event_name;
DROP INDEX IF EXISTS idx_analytics_events_event_date;

DROP TABLE IF EXISTS analytics_events;
DROP TABLE IF EXISTS analytics_events_raw;
DROP TABLE IF EXISTS analytics_event_batches;