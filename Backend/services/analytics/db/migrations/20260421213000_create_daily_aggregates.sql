-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_daily_active_users (
    event_date DATE PRIMARY KEY,
    dau INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS analytics_event_daily (
    id BIGSERIAL PRIMARY KEY,
    event_date DATE NOT NULL,
    event_name TEXT NOT NULL,
    total_count INT NOT NULL DEFAULT 0,
    unique_users INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_analytics_event_daily UNIQUE (event_date, event_name)
);

CREATE TABLE IF NOT EXISTS analytics_screen_daily (
    id BIGSERIAL PRIMARY KEY,
    event_date DATE NOT NULL,
    screen TEXT NOT NULL,
    views_count INT NOT NULL DEFAULT 0,
    unique_users INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_analytics_screen_daily UNIQUE (event_date, screen)
);

CREATE TABLE IF NOT EXISTS analytics_error_daily (
    id BIGSERIAL PRIMARY KEY,
    event_date DATE NOT NULL,
    screen TEXT NOT NULL,
    error_count INT NOT NULL DEFAULT 0,
    unique_users INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_analytics_error_daily UNIQUE (event_date, screen)
);

CREATE INDEX IF NOT EXISTS idx_analytics_event_daily_event_date
    ON analytics_event_daily(event_date);

CREATE INDEX IF NOT EXISTS idx_analytics_event_daily_event_name
    ON analytics_event_daily(event_name);

CREATE INDEX IF NOT EXISTS idx_analytics_screen_daily_event_date
    ON analytics_screen_daily(event_date);

CREATE INDEX IF NOT EXISTS idx_analytics_screen_daily_screen
    ON analytics_screen_daily(screen);

CREATE INDEX IF NOT EXISTS idx_analytics_error_daily_event_date
    ON analytics_error_daily(event_date);

CREATE INDEX IF NOT EXISTS idx_analytics_error_daily_screen
    ON analytics_error_daily(screen);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_error_daily_screen;
DROP INDEX IF EXISTS idx_analytics_error_daily_event_date;
DROP INDEX IF EXISTS idx_analytics_screen_daily_screen;
DROP INDEX IF EXISTS idx_analytics_screen_daily_event_date;
DROP INDEX IF EXISTS idx_analytics_event_daily_event_name;
DROP INDEX IF EXISTS idx_analytics_event_daily_event_date;

DROP TABLE IF EXISTS analytics_error_daily;
DROP TABLE IF EXISTS analytics_screen_daily;
DROP TABLE IF EXISTS analytics_event_daily;
DROP TABLE IF EXISTS analytics_daily_active_users;
