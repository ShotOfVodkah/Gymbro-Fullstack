package store

import (
	"context"
	"database/sql"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

type OverviewStoreRow struct {
	ActiveUsersToday int `db:"active_users_today"`
	ActiveUsersTotal int `db:"active_users_total"`
	TotalEventsToday int `db:"total_events_today"`
	TotalErrorsToday int `db:"total_errors_today"`
}

func (s *AnalyticsStore) GetOverviewMetrics(ctx context.Context) (*models.OverviewResponse, error) {
	var row OverviewStoreRow

	err := s.db.GetContext(ctx, &row, `
		SELECT
			COALESCE(
				(SELECT dau
				 FROM analytics_daily_active_users
				 ORDER BY event_date DESC
				 LIMIT 1), 0
			) AS active_users_today,

			COALESCE(
				(SELECT COUNT(DISTINCT user_id)
				 FROM analytics_events), 0
			) AS active_users_total,

			COALESCE(
				(SELECT SUM(total_count)
				 FROM analytics_event_daily
				 WHERE event_date = (SELECT MAX(event_date) FROM analytics_event_daily)
				), 0
			) AS total_events_today,

			COALESCE(
				(SELECT SUM(error_count)
				 FROM analytics_error_daily
				 WHERE event_date = (SELECT MAX(event_date) FROM analytics_error_daily)
				), 0
			) AS total_errors_today
	`)
	if err != nil {
		return nil, err
	}

	topScreens := []models.OverviewMetricItem{}
	err = s.db.SelectContext(ctx, &topScreens, `
		SELECT
			screen AS name,
			views_count AS count,
			unique_users
		FROM analytics_screen_daily
		WHERE event_date = (SELECT MAX(event_date) FROM analytics_screen_daily)
		ORDER BY views_count DESC, unique_users DESC, screen ASC
		LIMIT 5
	`)
	if err != nil && err != sql.ErrNoRows {
		return nil, err
	}

	topEvents := []models.OverviewMetricItem{}
	err = s.db.SelectContext(ctx, &topEvents, `
		SELECT
			event_name AS name,
			total_count AS count,
			unique_users
		FROM analytics_event_daily
		WHERE event_date = (SELECT MAX(event_date) FROM analytics_event_daily)
		ORDER BY total_count DESC, unique_users DESC, event_name ASC
		LIMIT 5
	`)
	if err != nil && err != sql.ErrNoRows {
		return nil, err
	}

	errorRate := 0.0
	if row.TotalEventsToday > 0 {
		errorRate = float64(row.TotalErrorsToday) / float64(row.TotalEventsToday)
	}

	return &models.OverviewResponse{
		ActiveUsersToday: row.ActiveUsersToday,
		ActiveUsersTotal: row.ActiveUsersTotal,
		TotalEventsToday: row.TotalEventsToday,
		TotalErrorsToday: row.TotalErrorsToday,
		ErrorRateToday:   errorRate,
		TopScreens:       topScreens,
		TopEvents:        topEvents,
	}, nil
}

func (s *AnalyticsStore) GetErrorMetrics(ctx context.Context) ([]models.ErrorMetricItem, error) {
	items := []models.ErrorMetricItem{}

	err := s.db.SelectContext(ctx, &items, `
		WITH latest_errors AS (
			SELECT
				event_date,
				screen,
				error_count,
				unique_users
			FROM analytics_error_daily
			WHERE event_date = (SELECT MAX(event_date) FROM analytics_error_daily)
		),
		retries AS (
			SELECT
				event_date,
				COALESCE(screen, 'unknown') AS screen,
				SUM(total_count) AS retry_count
			FROM analytics_event_daily
			LEFT JOIN (
				SELECT
					event_date AS e_date,
					event_name AS e_name,
					NULL::TEXT AS screen
				FROM analytics_event_daily
			) tmp ON 1=0
			WHERE event_name = 'error_retry_tapped'
			  AND event_date = (SELECT MAX(event_date) FROM analytics_event_daily)
			GROUP BY event_date, COALESCE(screen, 'unknown')
		)
		SELECT
			e.screen,
			e.error_count,
			e.unique_users,
			COALESCE(r.retry_count, 0) AS retry_count,
			CASE
				WHEN e.error_count > 0 THEN COALESCE(r.retry_count, 0)::float / e.error_count
				ELSE 0
			END AS retry_rate
		FROM latest_errors e
		LEFT JOIN retries r
			ON r.event_date = e.event_date
		   AND r.screen = e.screen
		ORDER BY e.error_count DESC, e.unique_users DESC, e.screen ASC
	`)
	if err != nil {
		return nil, err
	}

	if len(items) > 0 {
		type retryRow struct {
			Screen     string `db:"screen"`
			RetryCount int    `db:"retry_count"`
		}
		var retryRows []retryRow
		err = s.db.SelectContext(ctx, &retryRows, `
			SELECT
				COALESCE(screen, 'unknown') AS screen,
				COUNT(*) AS retry_count
			FROM analytics_events
			WHERE event_name = 'error_retry_tapped'
			  AND event_date = (SELECT MAX(event_date) FROM analytics_events)
			GROUP BY COALESCE(screen, 'unknown')
		`)
		if err == nil {
			retryMap := make(map[string]int, len(retryRows))
			for _, row := range retryRows {
				retryMap[row.Screen] = row.RetryCount
			}
			for i := range items {
				items[i].RetryCount = retryMap[items[i].Screen]
				if items[i].ErrorCount > 0 {
					items[i].RetryRate = float64(items[i].RetryCount) / float64(items[i].ErrorCount)
				}
			}
		}
	}

	return items, nil
}

func (s *AnalyticsStore) GetScreenMetrics(ctx context.Context) ([]models.ScreenMetricItem, error) {
	items := []models.ScreenMetricItem{}

	err := s.db.SelectContext(ctx, &items, `
		WITH latest_screens AS (
			SELECT
				event_date,
				screen,
				views_count,
				unique_users
			FROM analytics_screen_daily
			WHERE event_date = (SELECT MAX(event_date) FROM analytics_screen_daily)
		),
		latest_errors AS (
			SELECT
				event_date,
				screen,
				error_count,
				unique_users AS error_unique_users
			FROM analytics_error_daily
			WHERE event_date = (SELECT MAX(event_date) FROM analytics_error_daily)
		),
		retries AS (
			SELECT
				COALESCE(screen, 'unknown') AS screen,
				COUNT(*) AS retry_count
			FROM analytics_events
			WHERE event_name = 'error_retry_tapped'
			  AND event_date = (SELECT MAX(event_date) FROM analytics_events)
			GROUP BY COALESCE(screen, 'unknown')
		)
		SELECT
			s.screen,
			s.views_count,
			s.unique_users,
			COALESCE(e.error_count, 0) AS error_count,
			COALESCE(r.retry_count, 0) AS retry_count,
			CASE
				WHEN s.views_count > 0 THEN COALESCE(e.error_count, 0)::float / s.views_count
				ELSE 0
			END AS error_rate,
			CASE
				WHEN COALESCE(e.error_count, 0) > 0 THEN COALESCE(r.retry_count, 0)::float / e.error_count
				ELSE 0
			END AS retry_rate
		FROM latest_screens s
		LEFT JOIN latest_errors e
			ON e.event_date = s.event_date
		   AND e.screen = s.screen
		LEFT JOIN retries r
			ON r.screen = s.screen
		ORDER BY s.views_count DESC, s.unique_users DESC, s.screen ASC
	`)
	if err != nil {
		return nil, err
	}

	return items, nil
}

func (s *AnalyticsStore) GetTopEvents(ctx context.Context) ([]models.TopEventItem, error) {
	items := []models.TopEventItem{}

	err := s.db.SelectContext(ctx, &items, `
		SELECT
			event_name,
			total_count,
			unique_users
		FROM analytics_event_daily
		WHERE event_date = (SELECT MAX(event_date) FROM analytics_event_daily)
		ORDER BY total_count DESC, unique_users DESC, event_name ASC
		LIMIT 20
	`)
	if err != nil {
		return nil, err
	}

	return items, nil
}