-- +goose Up

CREATE TABLE IF NOT EXISTS user_perks (
    user_id BIGINT PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_streaks (
    user_id BIGINT PRIMARY KEY REFERENCES user_perks(user_id) ON DELETE CASCADE,

    current_streak_weeks INT NOT NULL DEFAULT 0,
    best_streak_weeks INT NOT NULL DEFAULT 0,

    weekly_goal INT NOT NULL DEFAULT 3,
    next_weekly_goal INT,

    completed_this_week INT NOT NULL DEFAULT 0,
    remaining_to_goal INT NOT NULL DEFAULT 3,

    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,

    is_goal_completed BOOLEAN NOT NULL DEFAULT FALSE,
    was_freeze_used_this_week BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT user_streaks_weekly_goal_check CHECK (weekly_goal BETWEEN 1 AND 7),
    CONSTRAINT user_streaks_next_weekly_goal_check CHECK (next_weekly_goal IS NULL OR next_weekly_goal BETWEEN 1 AND 7),
    CONSTRAINT user_streaks_current_streak_check CHECK (current_streak_weeks >= 0),
    CONSTRAINT user_streaks_best_streak_check CHECK (best_streak_weeks >= 0),
    CONSTRAINT user_streaks_completed_check CHECK (completed_this_week >= 0),
    CONSTRAINT user_streaks_remaining_check CHECK (remaining_to_goal >= 0)
);

CREATE TABLE IF NOT EXISTS achievement_definitions (
    id BIGSERIAL PRIMARY KEY,

    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_name TEXT NOT NULL,

    category TEXT NOT NULL,
    rarity TEXT NOT NULL,

    target_value INT NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT achievement_category_check CHECK (
        category IN (
            'workoutMilestones',
            'consistency',
            'timeChallenges',
            'social',
            'special'
        )
    ),
    CONSTRAINT achievement_rarity_check CHECK (
        rarity IN (
            'common',
            'rare',
            'epic',
            'legendary'
        )
    ),
    CONSTRAINT achievement_target_value_check CHECK (target_value > 0)
);

CREATE TABLE IF NOT EXISTS user_achievements (
    user_id BIGINT NOT NULL REFERENCES user_perks(user_id) ON DELETE CASCADE,
    achievement_code TEXT NOT NULL REFERENCES achievement_definitions(code) ON DELETE CASCADE,

    status TEXT NOT NULL DEFAULT 'locked',
    progress_current INT NOT NULL DEFAULT 0,
    progress_target INT NOT NULL DEFAULT 1,
    unlocked_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (user_id, achievement_code),

    CONSTRAINT user_achievement_status_check CHECK (status IN ('locked', 'unlocked')),
    CONSTRAINT user_achievement_progress_current_check CHECK (progress_current >= 0),
    CONSTRAINT user_achievement_progress_target_check CHECK (progress_target > 0)
);

CREATE TABLE IF NOT EXISTS perk_events (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL REFERENCES user_perks(user_id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS streak_freezes (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL REFERENCES user_perks(user_id) ON DELETE CASCADE,

    status TEXT NOT NULL DEFAULT 'available',
    source TEXT NOT NULL DEFAULT 'system',

    used_week_start_date DATE,
    used_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT streak_freeze_status_check CHECK (
        status IN ('available', 'used', 'expired')
    )
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id
    ON user_achievements(user_id);

CREATE INDEX IF NOT EXISTS idx_user_achievements_status
    ON user_achievements(status);

CREATE INDEX IF NOT EXISTS idx_perk_events_user_id
    ON perk_events(user_id);

CREATE INDEX IF NOT EXISTS idx_perk_events_type
    ON perk_events(event_type);

CREATE INDEX IF NOT EXISTS idx_perk_events_created_at
    ON perk_events(created_at);

CREATE INDEX IF NOT EXISTS idx_streak_freezes_user_id
    ON streak_freezes(user_id);

CREATE INDEX IF NOT EXISTS idx_streak_freezes_status
    ON streak_freezes(status);

-- +goose Down

DROP TABLE IF EXISTS streak_freezes;
DROP TABLE IF EXISTS perk_events;
DROP TABLE IF EXISTS user_achievements;
DROP TABLE IF EXISTS achievement_definitions;
DROP TABLE IF EXISTS user_streaks;
DROP TABLE IF EXISTS user_perks;