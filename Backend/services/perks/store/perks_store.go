package store

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jmoiron/sqlx"

	"github.com/alexandra-gritsaenko/gymbro-perks/types"
)

type PerksStore struct {
	db *sqlx.DB
}

func NewPerksStore(db *sqlx.DB) *PerksStore {
	return &PerksStore{db: db}
}

func (s *PerksStore) EnsureUser(ctx context.Context, userID int64) error {
	_, err := s.db.ExecContext(ctx, `
		INSERT INTO user_perks (user_id)
		VALUES ($1)
		ON CONFLICT (user_id) DO NOTHING
	`, userID)
	if err != nil {
		return err
	}

	weekStart, weekEnd := CurrentWeekRange()

	_, err = s.db.ExecContext(ctx, `
		INSERT INTO user_streaks (
			user_id,
			weekly_goal,
			completed_this_week,
			remaining_to_goal,
			week_start_date,
			week_end_date
		)
		VALUES ($1, 3, 0, 3, $2, $3)
		ON CONFLICT (user_id) DO NOTHING
	`, userID, weekStart, weekEnd)
	if err != nil {
		return err
	}

	_, err = s.db.ExecContext(ctx, `
		INSERT INTO user_achievements (
			user_id,
			achievement_code,
			status,
			progress_current,
			progress_target
		)
		SELECT
			$1,
			code,
			'locked',
			0,
			target_value
		FROM achievement_definitions
		WHERE is_active = TRUE
		ON CONFLICT (user_id, achievement_code) DO NOTHING
	`, userID)

	return err
}

func (s *PerksStore) SaveEvent(ctx context.Context, userID int64, request types.PerksEventRequest) error {
	if err := s.EnsureUser(ctx, userID); err != nil {
		return err
	}

	if request.Metadata == nil {
		request.Metadata = map[string]string{}
	}

	metadataBytes, err := json.Marshal(request.Metadata)
	if err != nil {
		return err
	}

	createdAt := request.CreatedAt
	if createdAt.IsZero() {
		createdAt = time.Now()
	}

	_, err = s.db.ExecContext(ctx, `
		INSERT INTO perk_events (
			user_id,
			event_type,
			metadata,
			created_at
		)
		VALUES ($1, $2, $3, $4)
	`, userID, request.Type, metadataBytes, createdAt)

	return err
}

func CurrentWeekRange() (time.Time, time.Time) {
	now := time.Now()
	weekday := int(now.Weekday())
	if weekday == 0 {
		weekday = 7
	}

	start := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location()).
		AddDate(0, 0, -(weekday - 1))

	end := start.AddDate(0, 0, 6)

	return start, end
}

func (s *PerksStore) IncrementCompletedWorkouts(ctx context.Context, userID int64) error {
	if err := s.EnsureUser(ctx, userID); err != nil {
		return err
	}

	_, err := s.db.ExecContext(ctx, `
		UPDATE user_perks
		SET
			completed_workouts = completed_workouts + 1,
			updated_at = NOW()
		WHERE user_id = $1
	`, userID)

	return err
}