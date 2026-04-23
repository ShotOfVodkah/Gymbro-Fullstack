-- +goose Up

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_date_event_name
    ON analytics_events(event_date, event_name);

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_date_user_id
    ON analytics_events(event_date, user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_date_app_version
    ON analytics_events(event_date, app_version);

CREATE INDEX IF NOT EXISTS idx_analytics_events_processing_status_server_received_at
    ON analytics_events(processing_status, server_received_at);

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_category
    ON analytics_events(event_category);

CREATE INDEX IF NOT EXISTS idx_analytics_invalid_events_received_at
    ON analytics_invalid_events(received_at);

CREATE INDEX IF NOT EXISTS idx_analytics_invalid_events_batch_id
    ON analytics_invalid_events(batch_id);

CREATE INDEX IF NOT EXISTS idx_analytics_invalid_events_reason
    ON analytics_invalid_events(reason);

CREATE INDEX IF NOT EXISTS idx_analytics_event_batches_received_at
    ON analytics_event_batches(received_at);

CREATE INDEX IF NOT EXISTS idx_analytics_event_batches_app_version
    ON analytics_event_batches(app_version);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_event_batches_app_version;
DROP INDEX IF EXISTS idx_analytics_event_batches_received_at;
DROP INDEX IF EXISTS idx_analytics_invalid_events_reason;
DROP INDEX IF EXISTS idx_analytics_invalid_events_batch_id;
DROP INDEX IF EXISTS idx_analytics_invalid_events_received_at;
DROP INDEX IF EXISTS idx_analytics_events_event_category;
DROP INDEX IF EXISTS idx_analytics_events_processing_status_server_received_at;
DROP INDEX IF EXISTS idx_analytics_events_event_date_app_version;
DROP INDEX IF EXISTS idx_analytics_events_event_date_user_id;
DROP INDEX IF EXISTS idx_analytics_events_event_date_event_name;