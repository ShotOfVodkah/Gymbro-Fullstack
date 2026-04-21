-- +goose Up

ALTER TABLE analytics_event_batches
ADD COLUMN IF NOT EXISTS batch_fingerprint TEXT;

ALTER TABLE analytics_events
ADD COLUMN IF NOT EXISTS event_fingerprint TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS ux_analytics_event_batches_batch_fingerprint
    ON analytics_event_batches(batch_fingerprint)
    WHERE batch_fingerprint IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_analytics_events_event_fingerprint
    ON analytics_events(event_fingerprint)
    WHERE event_fingerprint IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_fingerprint
    ON analytics_events(event_fingerprint);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_events_event_fingerprint;
DROP INDEX IF EXISTS ux_analytics_events_event_fingerprint;
DROP INDEX IF EXISTS ux_analytics_event_batches_batch_fingerprint;

ALTER TABLE analytics_events
DROP COLUMN IF EXISTS event_fingerprint;

ALTER TABLE analytics_event_batches
DROP COLUMN IF EXISTS batch_fingerprint;