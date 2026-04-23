-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_user_summary (
    user_id BIGINT PRIMARY KEY,

    active_days_last_7 INT NOT NULL DEFAULT 0,
    active_days_last_30 INT NOT NULL DEFAULT 0,

    sessions_count INT NOT NULL DEFAULT 0,
    workout_events_count INT NOT NULL DEFAULT 0,
    social_actions_count INT NOT NULL DEFAULT 0,
    error_events_count INT NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_user_summary_updated_at
    ON analytics_user_summary(updated_at);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_user_summary_updated_at;
DROP TABLE IF EXISTS analytics_user_summary;