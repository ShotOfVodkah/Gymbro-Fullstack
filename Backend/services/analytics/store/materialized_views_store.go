package store

import (
	"context"
	"database/sql"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

func (s *AnalyticsStore) RefreshMaterializedViews(ctx context.Context) error {
	_, err := s.db.ExecContext(ctx, `
		REFRESH MATERIALIZED VIEW analytics_dashboard_overview_mv
	`)
	if err != nil {
		return err
	}

	return nil
}

func (s *AnalyticsStore) GetDashboardOverviewFast(ctx context.Context) (*models.DashboardOverviewMVItem, error) {
	var item models.DashboardOverviewMVItem

	err := s.db.GetContext(ctx, &item, `
		SELECT
			event_date::text AS event_date,
			batches_received,
			events_received,
			events_accepted,
			events_rejected,
			backlog_pending,
			backlog_processing,
			backlog_failed,
			avg_processing_lag_seconds,
			max_processing_lag_seconds,
			processing_failures,
			dau,
			total_errors,
			invalid_rate
		FROM analytics_dashboard_overview_mv
		ORDER BY event_date DESC
		LIMIT 1
	`)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &item, nil
}