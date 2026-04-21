-- +goose Up

ALTER TABLE profiles
    ADD COLUMN IF NOT EXISTS bio TEXT NOT NULL DEFAULT '';

CREATE TABLE IF NOT EXISTS profile_settings (
    user_id INT PRIMARY KEY REFERENCES profiles (user_id) ON DELETE CASCADE,
    push_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    workout_reminders BOOLEAN NOT NULL DEFAULT TRUE,
    private_account BOOLEAN NOT NULL DEFAULT FALSE,
    show_activity BOOLEAN NOT NULL DEFAULT TRUE,
    discover_visibility BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS profile_statistics (
    user_id INT PRIMARY KEY REFERENCES profiles (user_id) ON DELETE CASCADE,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO profile_settings (user_id)
SELECT user_id FROM profiles
ON CONFLICT (user_id) DO NOTHING;

-- +goose Down

DROP TABLE IF EXISTS profile_statistics;
DROP TABLE IF EXISTS profile_settings;

ALTER TABLE profiles DROP COLUMN IF EXISTS bio;
