-- +goose Up
-- +goose StatementBegin

CREATE TABLE IF NOT EXISTS challenges (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    difficulty TEXT NOT NULL DEFAULT 'medium',
    cover_icon TEXT NOT NULL,
    accent_color TEXT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    target_value INTEGER NOT NULL CHECK (target_value > 0),
    unit TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS challenge_teams (
    id TEXT PRIMARY KEY,
    challenge_id TEXT NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    chat_id TEXT NOT NULL,
    team_name TEXT NOT NULL,
    team_avatar TEXT NOT NULL DEFAULT 'person.3.fill',
    status TEXT NOT NULL DEFAULT 'in_progress',
    current_value INTEGER NOT NULL DEFAULT 0,
    target_value INTEGER NOT NULL CHECK (target_value > 0),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,

    CONSTRAINT unique_challenge_chat_team UNIQUE (challenge_id, chat_id)
);

CREATE TABLE IF NOT EXISTS challenge_progress_events (
    id TEXT PRIMARY KEY,
    challenge_id TEXT NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    team_id TEXT NOT NULL REFERENCES challenge_teams(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,
    source_type TEXT NOT NULL,
    source_id TEXT NOT NULL,
    value INTEGER NOT NULL CHECK (value >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT unique_challenge_progress_source UNIQUE (challenge_id, team_id, source_type, source_id)
);

CREATE TABLE IF NOT EXISTS challenge_participant_stats (
    id TEXT PRIMARY KEY,
    challenge_id TEXT NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    team_id TEXT NOT NULL REFERENCES challenge_teams(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,
    contribution_value INTEGER NOT NULL DEFAULT 0,
    last_activity_at TIMESTAMPTZ,

    CONSTRAINT unique_challenge_team_user UNIQUE (challenge_id, team_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_challenges_status
    ON challenges(status);

CREATE INDEX IF NOT EXISTS idx_challenges_dates
    ON challenges(start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_challenge_teams_challenge_id
    ON challenge_teams(challenge_id);

CREATE INDEX IF NOT EXISTS idx_challenge_teams_chat_id
    ON challenge_teams(chat_id);

CREATE INDEX IF NOT EXISTS idx_challenge_progress_events_team_id
    ON challenge_progress_events(team_id);

CREATE INDEX IF NOT EXISTS idx_challenge_progress_events_user_id
    ON challenge_progress_events(user_id);

CREATE INDEX IF NOT EXISTS idx_challenge_participant_stats_team_id
    ON challenge_participant_stats(team_id);

CREATE INDEX IF NOT EXISTS idx_challenge_participant_stats_user_id
    ON challenge_participant_stats(user_id);

-- +goose StatementEnd


-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS challenge_participant_stats;
DROP TABLE IF EXISTS challenge_progress_events;
DROP TABLE IF EXISTS challenge_teams;
DROP TABLE IF EXISTS challenges;

-- +goose StatementEnd