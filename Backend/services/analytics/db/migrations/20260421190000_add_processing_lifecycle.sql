-- +goose Up

ALTER TABLE analytics_events
ADD COLUMN IF NOT EXISTS processing_started_at TIMESTAMPTZ;

ALTER TABLE analytics_events
ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ;

ALTER TABLE analytics_events
ADD COLUMN IF NOT EXISTS processing_error TEXT;

CREATE INDEX IF NOT EXISTS idx_analytics_events_processing_status_id
    ON analytics_events(processing_status, id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_processed_at
    ON analytics_events(processed_at);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_events_processed_at;
DROP INDEX IF EXISTS idx_analytics_events_processing_status_id;

ALTER TABLE analytics_events
DROP COLUMN IF EXISTS processing_error;

ALTER TABLE analytics_events
DROP COLUMN IF EXISTS processed_at;

ALTER TABLE analytics_events
DROP COLUMN IF EXISTS processing_started_at;