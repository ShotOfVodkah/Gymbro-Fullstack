-- +goose Up

ALTER TABLE analytics_events
ADD COLUMN IF NOT EXISTS request_id TEXT;

ALTER TABLE analytics_events
ADD COLUMN IF NOT EXISTS is_error_event BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_analytics_events_request_id
    ON analytics_events(request_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_is_error_event
    ON analytics_events(is_error_event);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_events_is_error_event;
DROP INDEX IF EXISTS idx_analytics_events_request_id;

ALTER TABLE analytics_events
DROP COLUMN IF EXISTS is_error_event;

ALTER TABLE analytics_events
DROP COLUMN IF EXISTS request_id;