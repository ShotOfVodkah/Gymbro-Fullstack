package store

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

func (s *AnalyticsStore) RebuildRetentionCohorts(ctx context.Context) error {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	_, err = tx.ExecContext(ctx, `DELETE FROM analytics_retention_cohorts`)
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		WITH registration_cohorts AS (
			SELECT
				user_id,
				MIN(event_date) AS cohort_date
			FROM analytics_events
			WHERE event_name = 'user_registered'
			GROUP BY user_id
		),
		user_activity AS (
			SELECT DISTINCT
				user_id,
				event_date
			FROM analytics_events
		),
		cohort_metrics AS (
			SELECT
				rc.cohort_date,
				COUNT(*) AS cohort_size,
				COUNT(*) FILTER (
					WHERE EXISTS (
						SELECT 1
						FROM user_activity ua
						WHERE ua.user_id = rc.user_id
						  AND ua.event_date = rc.cohort_date + INTERVAL '1 day'
					)
				) AS retained_d1,
				COUNT(*) FILTER (
					WHERE EXISTS (
						SELECT 1
						FROM user_activity ua
						WHERE ua.user_id = rc.user_id
						  AND ua.event_date = rc.cohort_date + INTERVAL '7 day'
					)
				) AS retained_d7,
				COUNT(*) FILTER (
					WHERE EXISTS (
						SELECT 1
						FROM user_activity ua
						WHERE ua.user_id = rc.user_id
						  AND ua.event_date = rc.cohort_date + INTERVAL '14 day'
					)
				) AS retained_d14,
				COUNT(*) FILTER (
					WHERE EXISTS (
						SELECT 1
						FROM user_activity ua
						WHERE ua.user_id = rc.user_id
						  AND ua.event_date = rc.cohort_date + INTERVAL '30 day'
					)
				) AS retained_d30
			FROM registration_cohorts rc
			GROUP BY rc.cohort_date
		)
		INSERT INTO analytics_retention_cohorts (
			cohort_date,
			cohort_size,
			retained_d1,
			retained_d7,
			retained_d14,
			retained_d30,
			retention_d1,
			retention_d7,
			retention_d14,
			retention_d30,
			created_at,
			updated_at
		)
		SELECT
			cohort_date,
			cohort_size,
			retained_d1,
			retained_d7,
			retained_d14,
			retained_d30,
			CASE WHEN cohort_size > 0 THEN retained_d1::double precision / cohort_size ELSE 0 END,
			CASE WHEN cohort_size > 0 THEN retained_d7::double precision / cohort_size ELSE 0 END,
			CASE WHEN cohort_size > 0 THEN retained_d14::double precision / cohort_size ELSE 0 END,
			CASE WHEN cohort_size > 0 THEN retained_d30::double precision / cohort_size ELSE 0 END,
			NOW(),
			NOW()
		FROM cohort_metrics
		ORDER BY cohort_date
	`)
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AnalyticsStore) GetRetentionCohorts(ctx context.Context) ([]models.RetentionCohortItem, error) {
	items := []models.RetentionCohortItem{}

	err := s.db.SelectContext(ctx, &items, `
		SELECT
			cohort_date::text AS cohort_date,
			cohort_size,
			retained_d1,
			retained_d7,
			retained_d14,
			retained_d30,
			retention_d1,
			retention_d7,
			retention_d14,
			retention_d30
		FROM analytics_retention_cohorts
		ORDER BY cohort_date DESC
	`)
	if err != nil {
		return nil, err
	}

	return items, nil
}