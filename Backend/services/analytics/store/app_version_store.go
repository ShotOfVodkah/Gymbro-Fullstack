package store

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/lib/pq"
)

func (s *AnalyticsStore) RebuildAppVersionDailyForDates(ctx context.Context, dates []string) error {
	if len(dates) == 0 {
		return nil
	}

	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	_, err = tx.ExecContext(ctx, `
		DELETE FROM analytics_app_version_daily
		WHERE event_date::text = ANY($1)
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		WITH base AS (
			SELECT
				event_date,
				app_version,
				COUNT(*) AS total_events,
				COUNT(DISTINCT user_id) AS unique_users,
				COUNT(*) FILTER (WHERE is_error_event = TRUE) AS error_count
			FROM analytics_events
			WHERE event_date::text = ANY($1)
			GROUP BY event_date, app_version
		),
		workout_share_opened AS (
			SELECT
				event_date,
				app_version,
				COUNT(DISTINCT user_id) AS opened_users
			FROM analytics_events
			WHERE event_date::text = ANY($1)
			  AND event_name = 'workout_share_opened'
			GROUP BY event_date, app_version
		),
		workout_share_done AS (
			SELECT
				event_date,
				app_version,
				COUNT(DISTINCT user_id) AS done_users
			FROM analytics_events
			WHERE event_date::text = ANY($1)
			  AND event_name = 'workout_share_done_tapped'
			GROUP BY event_date, app_version
		)
		INSERT INTO analytics_app_version_daily (
			event_date,
			app_version,
			total_events,
			unique_users,
			error_count,
			error_rate,
			workout_share_opened_users,
			workout_share_done_users,
			workout_share_conversion,
			created_at,
			updated_at
		)
		SELECT
			b.event_date,
			b.app_version,
			b.total_events,
			b.unique_users,
			b.error_count,
			CASE
				WHEN b.total_events > 0 THEN b.error_count::double precision / b.total_events
				ELSE 0
			END AS error_rate,
			COALESCE(o.opened_users, 0) AS workout_share_opened_users,
			COALESCE(d.done_users, 0) AS workout_share_done_users,
			CASE
				WHEN COALESCE(o.opened_users, 0) > 0 THEN COALESCE(d.done_users, 0)::double precision / o.opened_users
				ELSE 0
			END AS workout_share_conversion,
			NOW(),
			NOW()
		FROM base b
		LEFT JOIN workout_share_opened o
			ON o.event_date = b.event_date
		   AND o.app_version = b.app_version
		LEFT JOIN workout_share_done d
			ON d.event_date = b.event_date
		   AND d.app_version = b.app_version
		ORDER BY b.event_date, b.app_version
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AnalyticsStore) GetLatestAppVersions(ctx context.Context) ([]models.AppVersionDailyItem, error) {
	items := []models.AppVersionDailyItem{}

	err := s.db.SelectContext(ctx, &items, `
		SELECT
			event_date::text AS event_date,
			app_version,
			total_events,
			unique_users,
			error_count,
			error_rate,
			workout_share_opened_users,
			workout_share_done_users,
			workout_share_conversion
		FROM analytics_app_version_daily
		WHERE event_date = (SELECT MAX(event_date) FROM analytics_app_version_daily)
		ORDER BY unique_users DESC, total_events DESC, app_version ASC
	`)
	if err != nil {
		return nil, err
	}

	return items, nil
}