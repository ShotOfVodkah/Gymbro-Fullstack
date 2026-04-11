-- +goose Up

CREATE TABLE IF NOT EXISTS profiles (
    user_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT '',
    subtitle TEXT NOT NULL DEFAULT '',
    avatar_system_name TEXT NOT NULL DEFAULT 'person.circle.fill',
    badge TEXT,
    workouts_this_month INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- +goose Down

DROP TABLE IF EXISTS profiles;