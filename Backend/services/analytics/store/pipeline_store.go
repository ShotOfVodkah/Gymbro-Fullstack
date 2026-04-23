package store

import (
	"context"
	"database/sql"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

func (s *AnalyticsStore) RebuildPipelineDaily(ctx context.Context) error {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	_, err = tx.ExecContext(ctx, `DELETE FROM analytics_pipeline_daily`)
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		WITH batch_daily AS (
			SELECT
				received_at::date AS event_date,
				COUNT(*) AS batches_received,
				COALESCE(SUM(events_count), 0) AS events_received
			FROM analytics_event_batches
			GROUP BY received_at::date
		),
		accepted_daily AS (
			SELECT
				server_received_at::date AS event_date,
				COUNT(*) AS events_accepted,
				COUNT(*) FILTER (WHERE processing_status = 'failed') AS processing_failures,
				COALESCE(AVG(EXTRACT(EPOCH FROM (COALESCE(processed_at, NOW()) - server_received_at))), 0) AS avg_processing_lag_seconds,
				COALESCE(MAX(EXTRACT(EPOCH FROM (COALESCE(processed_at, NOW()) - server_received_at))), 0) AS max_processing_lag_seconds
			FROM analytics_events
			GROUP BY server_received_at::date
		),
		rejected_daily AS (
			SELECT
				received_at::date AS event_date,
				COUNT(*) AS events_rejected
			FROM analytics_invalid_events
			GROUP BY received_at::date
		),
		all_dates AS (
			SELECT event_date FROM batch_daily
			UNION
			SELECT event_date FROM accepted_daily
			UNION
			SELECT event_date FROM rejected_daily
		),
		backlog AS (
			SELECT
				COUNT(*) FILTER (WHERE processing_status = 'pending') AS backlog_pending,
				COUNT(*) FILTER (WHERE processing_status = 'processing') AS backlog_processing,
				COUNT(*) FILTER (WHERE processing_status = 'failed') AS backlog_failed
			FROM analytics_events
		)
		INSERT INTO analytics_pipeline_daily (
			event_date,
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
			created_at,
			updated_at
		)
		SELECT
			d.event_date,
			COALESCE(b.batches_received, 0),
			COALESCE(b.events_received, 0),
			COALESCE(a.events_accepted, 0),
			COALESCE(r.events_rejected, 0),
			bl.backlog_pending,
			bl.backlog_processing,
			bl.backlog_failed,
			COALESCE(a.avg_processing_lag_seconds, 0),
			COALESCE(a.max_processing_lag_seconds, 0),
			COALESCE(a.processing_failures, 0),
			NOW(),
			NOW()
		FROM all_dates d
		LEFT JOIN batch_daily b ON b.event_date = d.event_date
		LEFT JOIN accepted_daily a ON a.event_date = d.event_date
		LEFT JOIN rejected_daily r ON r.event_date = d.event_date
		CROSS JOIN backlog bl
		ORDER BY d.event_date
	`)
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AnalyticsStore) GetPipelineOverview(ctx context.Context) (*models.PipelineOverviewItem, error) {
	var item models.PipelineOverviewItem

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
			processing_failures
		FROM analytics_pipeline_daily
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

func (s *AnalyticsStore) GetBatchStatus(ctx context.Context, batchID string) (*models.BatchStatusResponse, error) {
	var item models.BatchStatusItem
	err := s.db.GetContext(ctx, &item, `
		SELECT
			batch_id,
			user_id,
			events_count,
			status,
			source,
			COALESCE(app_version, '') AS app_version,
			COALESCE(platform, '') AS platform,
			received_at::text AS received_at
		FROM analytics_event_batches
		WHERE batch_id = $1
	`, batchID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	var accepted, pending, processing, processed, failed int
	err = s.db.QueryRowContext(ctx, `
		SELECT
			COUNT(*) AS accepted_events,
			COUNT(*) FILTER (WHERE processing_status = 'pending') AS pending_events,
			COUNT(*) FILTER (WHERE processing_status = 'processing') AS processing_events,
			COUNT(*) FILTER (WHERE processing_status = 'processed') AS processed_events,
			COUNT(*) FILTER (WHERE processing_status = 'failed') AS failed_events
		FROM analytics_events
		WHERE batch_id = $1
	`, batchID).Scan(&accepted, &pending, &processing, &processed, &failed)
	if err != nil {
		return nil, err
	}

	var rejected int
	err = s.db.QueryRowContext(ctx, `
		SELECT COUNT(*)
		FROM analytics_invalid_events
		WHERE batch_id = $1
	`, batchID).Scan(&rejected)
	if err != nil {
		return nil, err
	}

	return &models.BatchStatusResponse{
		Item:             &item,
		AcceptedEvents:   accepted,
		RejectedEvents:   rejected,
		PendingEvents:    pending,
		ProcessingEvents: processing,
		ProcessedEvents:  processed,
		FailedEvents:     failed,
	}, nil
}

func (s *AnalyticsStore) GetInvalidEvents(ctx context.Context, limit int) ([]models.InvalidEventItem, error) {
	items := []models.InvalidEventItem{}

	err := s.db.SelectContext(ctx, &items, `
		SELECT
			id,
			COALESCE(batch_id, '') AS batch_id,
			user_id,
			COALESCE(request_id, '') AS request_id,
			event_index,
			COALESCE(event_name, '') AS event_name,
			reason,
			received_at::text AS received_at
		FROM analytics_invalid_events
		ORDER BY received_at DESC, id DESC
		LIMIT $1
	`, limit)
	if err != nil {
		return nil, err
	}

	return items, nil
}