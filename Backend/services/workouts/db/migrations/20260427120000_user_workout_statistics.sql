-- +goose Up
CREATE TABLE IF NOT EXISTS user_workout_statistics (
    user_id                TEXT         PRIMARY KEY,
    total_sessions         INT          NOT NULL DEFAULT 0,
    sum_exercise_minutes   BIGINT       NOT NULL DEFAULT 0,
    dow_counts             JSONB        NOT NULL DEFAULT '[]'::jsonb,
    muscle_group_counts    JSONB        NOT NULL DEFAULT '{}'::jsonb,
    workout_type_counts    JSONB        NOT NULL DEFAULT '{}'::jsonb,
    updated_at             TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_completed
    ON workout_sessions (user_id, completed_at);

-- +goose Down
DROP TABLE IF EXISTS user_workout_statistics;
DROP INDEX IF EXISTS idx_workout_sessions_user_completed;
