package store

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/lib/pq"
)

func (s *AnalyticsStore) RebuildDailyAggregatesForDates(ctx context.Context, dates []string) error {
	if len(dates) == 0 {
		return nil
	}

	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	// DAU
	_, err = tx.ExecContext(ctx, `
		DELETE FROM analytics_daily_active_users
		WHERE event_date = ANY($1)
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		INSERT INTO analytics_daily_active_users (event_date, dau, created_at, updated_at)
		SELECT
			event_date,
			COUNT(DISTINCT user_id) AS dau,
			NOW(),
			NOW()
		FROM analytics_events
		WHERE event_date::text = ANY($1)
		GROUP BY event_date
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	// event daily
	_, err = tx.ExecContext(ctx, `
		DELETE FROM analytics_event_daily
		WHERE event_date::text = ANY($1)
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		INSERT INTO analytics_event_daily (event_date, event_name, total_count, unique_users, created_at, updated_at)
		SELECT
			event_date,
			event_name,
			COUNT(*) AS total_count,
			COUNT(DISTINCT user_id) AS unique_users,
			NOW(),
			NOW()
		FROM analytics_events
		WHERE event_date::text = ANY($1)
		GROUP BY event_date, event_name
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	// screen daily
	_, err = tx.ExecContext(ctx, `
		DELETE FROM analytics_screen_daily
		WHERE event_date::text = ANY($1)
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		INSERT INTO analytics_screen_daily (event_date, screen, views_count, unique_users, created_at, updated_at)
		SELECT
			event_date,
			screen,
			COUNT(*) AS views_count,
			COUNT(DISTINCT user_id) AS unique_users,
			NOW(),
			NOW()
		FROM analytics_events
		WHERE event_date::text = ANY($1)
		  AND screen IS NOT NULL
		  AND screen <> ''
		GROUP BY event_date, screen
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	// error daily
	_, err = tx.ExecContext(ctx, `
		DELETE FROM analytics_error_daily
		WHERE event_date::text = ANY($1)
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		INSERT INTO analytics_error_daily (event_date, screen, error_count, unique_users, created_at, updated_at)
		SELECT
			event_date,
			COALESCE(screen, 'unknown') AS screen,
			COUNT(*) AS error_count,
			COUNT(DISTINCT user_id) AS unique_users,
			NOW(),
			NOW()
		FROM analytics_events
		WHERE event_date::text = ANY($1)
		  AND is_error_event = TRUE
		GROUP BY event_date, COALESCE(screen, 'unknown')
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	// feature usage daily
	_, err = tx.ExecContext(ctx, `
		DELETE FROM feature_usage_daily
		WHERE event_date::text = ANY($1)
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		INSERT INTO feature_usage_daily (
			event_date,
			feature_name,
			total_count,
			unique_users,
			created_at,
			updated_at
		)
		SELECT
			event_date,
			event_category AS feature_name,
			COUNT(*) AS total_count,
			COUNT(DISTINCT user_id) AS unique_users,
			NOW(),
			NOW()
		FROM analytics_events
		WHERE event_date::text = ANY($1)
		  AND event_category IS NOT NULL
		  AND event_category <> ''
		GROUP BY event_date, event_category
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AnalyticsStore) GetFeatureUsageDailyLatest(ctx context.Context) ([]models.FeatureUsageDailyItem, error) {
	items := []models.FeatureUsageDailyItem{}

	err := s.db.SelectContext(ctx, &items, `
		SELECT
			event_date::text AS event_date,
			feature_name,
			total_count,
			unique_users
		FROM feature_usage_daily
		WHERE event_date = (SELECT MAX(event_date) FROM feature_usage_daily)
		ORDER BY total_count DESC, unique_users DESC, feature_name ASC
	`)
	if err != nil {
		return nil, err
	}

	return items, nil
}