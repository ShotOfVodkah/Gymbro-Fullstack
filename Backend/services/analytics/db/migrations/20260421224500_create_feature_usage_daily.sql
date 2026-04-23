-- +goose Up

CREATE TABLE IF NOT EXISTS feature_usage_daily (
    id BIGSERIAL PRIMARY KEY,
    event_date DATE NOT NULL,
    feature_name TEXT NOT NULL,
    total_count INT NOT NULL DEFAULT 0,
    unique_users INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_feature_usage_daily UNIQUE (event_date, feature_name)
);

CREATE INDEX IF NOT EXISTS idx_feature_usage_daily_event_date
    ON feature_usage_daily(event_date);

CREATE INDEX IF NOT EXISTS idx_feature_usage_daily_feature_name
    ON feature_usage_daily(feature_name);

-- +goose Down

DROP INDEX IF EXISTS idx_feature_usage_daily_feature_name;
DROP INDEX IF EXISTS idx_feature_usage_daily_event_date;

DROP TABLE IF EXISTS feature_usage_daily;