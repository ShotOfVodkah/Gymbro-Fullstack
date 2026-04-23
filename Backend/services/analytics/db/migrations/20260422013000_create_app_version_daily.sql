-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_app_version_daily (
    id BIGSERIAL PRIMARY KEY,
    event_date DATE NOT NULL,
    app_version TEXT NOT NULL,

    total_events INT NOT NULL DEFAULT 0,
    unique_users INT NOT NULL DEFAULT 0,
    error_count INT NOT NULL DEFAULT 0,
    error_rate DOUBLE PRECISION NOT NULL DEFAULT 0,

    workout_share_opened_users INT NOT NULL DEFAULT 0,
    workout_share_done_users INT NOT NULL DEFAULT 0,
    workout_share_conversion DOUBLE PRECISION NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_analytics_app_version_daily UNIQUE (event_date, app_version)
);

CREATE INDEX IF NOT EXISTS idx_analytics_app_version_daily_event_date
    ON analytics_app_version_daily(event_date);

CREATE INDEX IF NOT EXISTS idx_analytics_app_version_daily_app_version
    ON analytics_app_version_daily(app_version);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_app_version_daily_app_version;
DROP INDEX IF EXISTS idx_analytics_app_version_daily_event_date;

DROP TABLE IF EXISTS analytics_app_version_daily;