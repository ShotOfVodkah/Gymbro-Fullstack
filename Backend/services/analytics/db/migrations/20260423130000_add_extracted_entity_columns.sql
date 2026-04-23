-- +goose Up

ALTER TABLE analytics_events
ADD COLUMN IF NOT EXISTS workout_id TEXT,
ADD COLUMN IF NOT EXISTS post_id TEXT,
ADD COLUMN IF NOT EXISTS person_id TEXT,
ADD COLUMN IF NOT EXISTS target_user_id TEXT,
ADD COLUMN IF NOT EXISTS community_id TEXT;

CREATE INDEX IF NOT EXISTS idx_analytics_events_workout_id
    ON analytics_events(workout_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_post_id
    ON analytics_events(post_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_person_id
    ON analytics_events(person_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_target_user_id
    ON analytics_events(target_user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_community_id
    ON analytics_events(community_id);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_events_community_id;
DROP INDEX IF EXISTS idx_analytics_events_target_user_id;
DROP INDEX IF EXISTS idx_analytics_events_person_id;
DROP INDEX IF EXISTS idx_analytics_events_post_id;
DROP INDEX IF EXISTS idx_analytics_events_workout_id;

ALTER TABLE analytics_events
DROP COLUMN IF EXISTS community_id,
DROP COLUMN IF EXISTS target_user_id,
DROP COLUMN IF EXISTS person_id,
DROP COLUMN IF EXISTS post_id,
DROP COLUMN IF EXISTS workout_id;