-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_funnel_daily (
    id BIGSERIAL PRIMARY KEY,
    event_date DATE NOT NULL,
    funnel_name TEXT NOT NULL,
    step_order INT NOT NULL,
    step_name TEXT NOT NULL,
    users_count INT NOT NULL DEFAULT 0,
    conversion_from_prev DOUBLE PRECISION NOT NULL DEFAULT 0,
    conversion_from_start DOUBLE PRECISION NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_analytics_funnel_daily UNIQUE (event_date, funnel_name, step_order)
);

CREATE INDEX IF NOT EXISTS idx_analytics_funnel_daily_event_date
    ON analytics_funnel_daily(event_date);

CREATE INDEX IF NOT EXISTS idx_analytics_funnel_daily_funnel_name
    ON analytics_funnel_daily(funnel_name);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_funnel_daily_funnel_name;
DROP INDEX IF EXISTS idx_analytics_funnel_daily_event_date;

DROP TABLE IF EXISTS analytics_funnel_daily;