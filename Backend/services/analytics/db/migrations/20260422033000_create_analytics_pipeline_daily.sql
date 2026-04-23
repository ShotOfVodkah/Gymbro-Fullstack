-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_pipeline_daily (
    event_date DATE PRIMARY KEY,

    batches_received INT NOT NULL DEFAULT 0,
    events_received INT NOT NULL DEFAULT 0,
    events_accepted INT NOT NULL DEFAULT 0,
    events_rejected INT NOT NULL DEFAULT 0,

    backlog_pending INT NOT NULL DEFAULT 0,
    backlog_processing INT NOT NULL DEFAULT 0,
    backlog_failed INT NOT NULL DEFAULT 0,

    avg_processing_lag_seconds DOUBLE PRECISION NOT NULL DEFAULT 0,
    max_processing_lag_seconds DOUBLE PRECISION NOT NULL DEFAULT 0,

    processing_failures INT NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_pipeline_daily_updated_at
    ON analytics_pipeline_daily(updated_at);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_pipeline_daily_updated_at;
DROP TABLE IF EXISTS analytics_pipeline_daily;