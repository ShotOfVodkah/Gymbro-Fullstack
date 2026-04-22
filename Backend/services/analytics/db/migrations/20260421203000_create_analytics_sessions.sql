-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_id TEXT NOT NULL,

    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ NOT NULL,
    duration_seconds BIGINT NOT NULL DEFAULT 0,

    events_count INT NOT NULL DEFAULT 0,
    unique_screens_count INT NOT NULL DEFAULT 0,

    has_error BOOLEAN NOT NULL DEFAULT FALSE,

    has_navigation_activity BOOLEAN NOT NULL DEFAULT FALSE,
    has_workout_activity BOOLEAN NOT NULL DEFAULT FALSE,
    has_social_activity BOOLEAN NOT NULL DEFAULT FALSE,
    has_chat_activity BOOLEAN NOT NULL DEFAULT FALSE,
    has_calendar_activity BOOLEAN NOT NULL DEFAULT FALSE,
    has_profile_activity BOOLEAN NOT NULL DEFAULT FALSE,
    has_settings_activity BOOLEAN NOT NULL DEFAULT FALSE,
    has_sharing_activity BOOLEAN NOT NULL DEFAULT FALSE,

    activity_type TEXT NOT NULL DEFAULT 'unknown',

    platform TEXT,
    app_version TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_analytics_sessions_user_session UNIQUE (user_id, session_id)
);

CREATE INDEX IF NOT EXISTS idx_analytics_sessions_user_id
    ON analytics_sessions(user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_sessions_session_id
    ON analytics_sessions(session_id);

CREATE INDEX IF NOT EXISTS idx_analytics_sessions_started_at
    ON analytics_sessions(started_at);

CREATE INDEX IF NOT EXISTS idx_analytics_sessions_activity_type
    ON analytics_sessions(activity_type);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_sessions_activity_type;
DROP INDEX IF EXISTS idx_analytics_sessions_started_at;
DROP INDEX IF EXISTS idx_analytics_sessions_session_id;
DROP INDEX IF EXISTS idx_analytics_sessions_user_id;

DROP TABLE IF EXISTS analytics_sessions;