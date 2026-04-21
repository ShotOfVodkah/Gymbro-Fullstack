package store

import (
	"context"
	"strings"
	"time"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/lib/pq"
)

func (s *AnalyticsStore) ClaimPendingEvents(ctx context.Context, limit int) ([]models.ProcessableEvent, error) {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer func() {
		_ = tx.Rollback()
	}()

	var ids []int64
	err = tx.SelectContext(ctx, &ids, `
		SELECT id
		FROM analytics_events
		WHERE processing_status = 'pending'
		ORDER BY id
		LIMIT $1
		FOR UPDATE SKIP LOCKED
	`, limit)
	if err != nil {
		return nil, err
	}

	if len(ids) == 0 {
		if err := tx.Commit(); err != nil {
			return nil, err
		}
		return []models.ProcessableEvent{}, nil
	}

	_, err = tx.ExecContext(ctx, `
		UPDATE analytics_events
		SET
			processing_status = 'processing',
			processing_started_at = NOW(),
			processing_error = NULL
		WHERE id = ANY($1)
	`, pq.Array(ids))
	if err != nil {
		return nil, err
	}

	events := []models.ProcessableEvent{}
	err = tx.SelectContext(ctx, &events, `
		SELECT
			id,
			batch_id,
			user_id,
			session_id,
			event_name,
			event_date::text AS event_date,
			event_time,
			screen,
			platform,
			app_version,
			event_category,
			is_error_event,
			entity_type,
			entity_id,
			properties,
			request_id
		FROM analytics_events
		WHERE id = ANY($1)
		ORDER BY id
	`, pq.Array(ids))
	if err != nil {
		return nil, err
	}

	if err := tx.Commit(); err != nil {
		return nil, err
	}

	return events, nil
}

func (s *AnalyticsStore) MarkEventsProcessed(ctx context.Context, ids []int64) error {
	if len(ids) == 0 {
		return nil
	}

	_, err := s.db.ExecContext(ctx, `
		UPDATE analytics_events
		SET
			processing_status = 'processed',
			processed_at = NOW(),
			processing_error = NULL
		WHERE id = ANY($1)
	`, pq.Array(ids))
	return err
}

func (s *AnalyticsStore) MarkEventsFailed(ctx context.Context, ids []int64, reason string) error {
	if len(ids) == 0 {
		return nil
	}

	reason = strings.TrimSpace(reason)
	if reason == "" {
		reason = "unknown processing error"
	}

	if len(reason) > 2000 {
		reason = reason[:2000]
	}

	_, err := s.db.ExecContext(ctx, `
		UPDATE analytics_events
		SET
			processing_status = 'failed',
			processing_error = $2
		WHERE id = ANY($1)
	`, pq.Array(ids), reason)
	return err
}

func (s *AnalyticsStore) ResetStuckProcessingEvents(ctx context.Context, olderThan time.Duration) error {
	_, err := s.db.ExecContext(ctx, `
		UPDATE analytics_events
		SET
			processing_status = 'pending',
			processing_error = 'reset after stuck processing',
			processing_started_at = NULL
		WHERE processing_status = 'processing'
		  AND processing_started_at IS NOT NULL
		  AND processing_started_at < NOW() - ($1 * INTERVAL '1 second')
	`, int64(olderThan.Seconds()))
	return err
}