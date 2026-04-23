package store

import (
	"context"
)

func (s *AnalyticsStore) CleanupRawEvents(ctx context.Context, retentionDays int) error {
	_, err := s.db.ExecContext(ctx, `
		DELETE FROM analytics_events_raw
		WHERE received_at < NOW() - ($1 * INTERVAL '1 day')
	`, retentionDays)
	return err
}

func (s *AnalyticsStore) CleanupInvalidEvents(ctx context.Context, retentionDays int) error {
	_, err := s.db.ExecContext(ctx, `
		DELETE FROM analytics_invalid_events
		WHERE received_at < NOW() - ($1 * INTERVAL '1 day')
	`, retentionDays)
	return err
}