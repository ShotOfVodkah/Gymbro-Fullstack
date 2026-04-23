-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_data_quality_daily (
    id BIGSERIAL PRIMARY KEY,
    event_date DATE NOT NULL,
    app_version TEXT NOT NULL,

    events_received INT NOT NULL DEFAULT 0,
    events_accepted INT NOT NULL DEFAULT 0,
    events_rejected INT NOT NULL DEFAULT 0,

    invalid_rate DOUBLE PRECISION NOT NULL DEFAULT 0,

    unknown_events_count INT NOT NULL DEFAULT 0,
    unknown_events_rate DOUBLE PRECISION NOT NULL DEFAULT 0,

    missing_required_fields_count INT NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_analytics_data_quality_daily UNIQUE (event_date, app_version)
);

CREATE INDEX IF NOT EXISTS idx_analytics_data_quality_daily_event_date
    ON analytics_data_quality_daily(event_date);

CREATE INDEX IF NOT EXISTS idx_analytics_data_quality_daily_app_version
    ON analytics_data_quality_daily(app_version);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_data_quality_daily_app_version;
DROP INDEX IF EXISTS idx_analytics_data_quality_daily_event_date;

DROP TABLE IF EXISTS analytics_data_quality_daily;