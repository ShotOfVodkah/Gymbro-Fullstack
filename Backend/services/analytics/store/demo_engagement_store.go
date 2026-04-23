package store

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

func (s *AnalyticsStore) GetDemoEngagementSection(ctx context.Context) (*models.DemoEngagementSection, error) {
	var section models.DemoEngagementSection

	err := s.db.GetContext(ctx, &section, `
		WITH user_base AS (
			SELECT
				user_id,
				active_days_last_7,
				active_days_last_30,
				sessions_count,
				workout_events_count,
				social_actions_count
			FROM analytics_user_summary
		)
		SELECT
			COALESCE(AVG(active_days_last_7::double precision), 0) AS average_active_days_last_7,
			COALESCE(AVG(active_days_last_30::double precision), 0) AS average_active_days_last_30,
			COALESCE(AVG(sessions_count::double precision), 0) AS average_sessions_per_user,
			COUNT(*) FILTER (WHERE workout_events_count > 0) AS users_with_workout_activity,
			COUNT(*) FILTER (WHERE social_actions_count > 0) AS users_with_social_activity
		FROM user_base
	`)
	if err != nil {
		return nil, err
	}

	return &section, nil
}