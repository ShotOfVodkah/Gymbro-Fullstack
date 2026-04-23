package store

import (
	"context"
	"database/sql"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/lib/pq"
)

func (s *AnalyticsStore) RebuildUserSummaries(ctx context.Context, userIDs []int64) error {
	if len(userIDs) == 0 {
		return nil
	}

	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	_, err = tx.ExecContext(ctx, `
		DELETE FROM analytics_user_summary
		WHERE user_id = ANY($1)
	`, pq.Array(userIDs))
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		WITH target_users AS (
			SELECT DISTINCT unnest($1::bigint[]) AS user_id
		),
		base AS (
			SELECT
				tu.user_id,

				COALESCE((
					SELECT COUNT(DISTINCT ae.event_date)
					FROM analytics_events ae
					WHERE ae.user_id = tu.user_id
					AND ae.event_date >= CURRENT_DATE - INTERVAL '6 day'
				), 0) AS active_days_last_7,

				COALESCE((
					SELECT COUNT(DISTINCT ae.event_date)
					FROM analytics_events ae
					WHERE ae.user_id = tu.user_id
					AND ae.event_date >= CURRENT_DATE - INTERVAL '29 day'
				), 0) AS active_days_last_30,

				COALESCE((
					SELECT COUNT(*)
					FROM analytics_sessions s
					WHERE s.user_id = tu.user_id
				), 0) AS sessions_count,

				COALESCE((
					SELECT COUNT(*)
					FROM analytics_events ae
					WHERE ae.user_id = tu.user_id
					AND ae.event_category = 'workout'
				), 0) AS workout_events_count,

				COALESCE((
					SELECT COUNT(*)
					FROM analytics_events ae
					WHERE ae.user_id = tu.user_id
					AND ae.event_category IN ('social', 'chat', 'sharing')
				), 0) AS social_actions_count,

				COALESCE((
					SELECT COUNT(*)
					FROM analytics_events ae
					WHERE ae.user_id = tu.user_id
					AND ae.is_error_event = TRUE
				), 0) AS error_events_count
			FROM target_users tu
		)
		INSERT INTO analytics_user_summary (
			user_id,
			active_days_last_7,
			active_days_last_30,
			sessions_count,
			workout_events_count,
			social_actions_count,
			error_events_count,
			created_at,
			updated_at
		)
		SELECT
			user_id,
			active_days_last_7,
			active_days_last_30,
			sessions_count,
			workout_events_count,
			social_actions_count,
			error_events_count,
			NOW(),
			NOW()
		FROM base
	`, pq.Array(userIDs))
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AnalyticsStore) GetUserSummary(ctx context.Context, userID int64) (*models.UserSummaryItem, error) {
	var item models.UserSummaryItem

	err := s.db.GetContext(ctx, &item, `
		SELECT
			user_id,
			active_days_last_7,
			active_days_last_30,
			sessions_count,
			workout_events_count,
			social_actions_count,
			error_events_count
		FROM analytics_user_summary
		WHERE user_id = $1
	`, userID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &item, nil
}