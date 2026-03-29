-- +goose Up

CREATE TABLE workout_sessions (
    id           TEXT        PRIMARY KEY,
    user_id      TEXT        NOT NULL,
    workout_id   TEXT        REFERENCES workouts(id) ON DELETE SET NULL,
    workout_name TEXT        NOT NULL,
    workout_type TEXT        NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE session_exercises (
    id               SERIAL      PRIMARY KEY,
    session_id       TEXT        NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    exercise_id      TEXT        REFERENCES exercises(id) ON DELETE SET NULL,
    exercise_name    TEXT        NOT NULL,
    exercise_type    TEXT        NOT NULL,
    muscle_group     TEXT        NOT NULL,
    position         INT         NOT NULL DEFAULT 0,
    sets             INT,
    reps             INT,
    weight_kg        FLOAT,
    duration_minutes INT,
    pace             TEXT,
    hold_seconds     INT,
    breath_count     INT
);

CREATE INDEX idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_completed_at ON workout_sessions(completed_at DESC);

-- +goose Down
DROP TABLE session_exercises;
DROP TABLE workout_sessions;
