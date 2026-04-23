package store

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

func (s *AnalyticsStore) GetResearchSocialVsNonSocial(ctx context.Context) (*models.ResearchComparisonResponse, error) {
	items := []models.ResearchGroupMetrics{}

	err := s.db.SelectContext(ctx, &items, `
		WITH user_groups AS (
			SELECT
				user_id,
				CASE
					WHEN social_actions_count > 0 THEN 'with_social_activity'
					ELSE 'without_social_activity'
				END AS group_name,
				active_days_last_7,
				active_days_last_30,
				sessions_count,
				workout_events_count,
				social_actions_count,
				error_events_count
			FROM analytics_user_summary
		)
		SELECT
			group_name,
			COUNT(*) AS users_count,
			COALESCE(AVG(active_days_last_7::double precision), 0) AS average_active_days_last_7,
			COALESCE(AVG(active_days_last_30::double precision), 0) AS average_active_days_last_30,
			COALESCE(AVG(sessions_count::double precision), 0) AS average_sessions_count,
			COALESCE(AVG(workout_events_count::double precision), 0) AS average_workout_events,
			COALESCE(AVG(social_actions_count::double precision), 0) AS average_social_actions,
			COALESCE(AVG(error_events_count::double precision), 0) AS average_error_events
		FROM user_groups
		GROUP BY group_name
		ORDER BY group_name
	`)
	if err != nil {
		return nil, err
	}

	return &models.ResearchComparisonResponse{
		Title:  "Social activity vs non-social activity",
		Groups: items,
	}, nil
}

func (s *AnalyticsStore) GetResearchSharingVsNonSharing(ctx context.Context) (*models.ResearchComparisonResponse, error) {
	items := []models.ResearchGroupMetrics{}

	err := s.db.SelectContext(ctx, &items, `
		WITH sharing_users AS (
			SELECT DISTINCT user_id
			FROM analytics_events
			WHERE event_name IN (
				'workout_share_opened',
				'workout_share_submit_tapped',
				'workout_share_submit_succeeded',
				'workout_share_done_tapped'
			)
		),
		user_groups AS (
			SELECT
				us.user_id,
				CASE
					WHEN su.user_id IS NOT NULL THEN 'with_sharing'
					ELSE 'without_sharing'
				END AS group_name,
				us.active_days_last_7,
				us.active_days_last_30,
				us.sessions_count,
				us.workout_events_count,
				us.social_actions_count,
				us.error_events_count
			FROM analytics_user_summary us
			LEFT JOIN sharing_users su
				ON su.user_id = us.user_id
		)
		SELECT
			group_name,
			COUNT(*) AS users_count,
			COALESCE(AVG(active_days_last_7::double precision), 0) AS average_active_days_last_7,
			COALESCE(AVG(active_days_last_30::double precision), 0) AS average_active_days_last_30,
			COALESCE(AVG(sessions_count::double precision), 0) AS average_sessions_count,
			COALESCE(AVG(workout_events_count::double precision), 0) AS average_workout_events,
			COALESCE(AVG(social_actions_count::double precision), 0) AS average_social_actions,
			COALESCE(AVG(error_events_count::double precision), 0) AS average_error_events
		FROM user_groups
		GROUP BY group_name
		ORDER BY group_name
	`)
	if err != nil {
		return nil, err
	}

	return &models.ResearchComparisonResponse{
		Title:  "Workout sharing vs non-sharing",
		Groups: items,
	}, nil
}

func (s *AnalyticsStore) GetResearchWorkoutCompletionEngagement(ctx context.Context) (*models.ResearchComparisonResponse, error) {
	items := []models.ResearchGroupMetrics{}

	err := s.db.SelectContext(ctx, &items, `
		WITH completed_users AS (
			SELECT DISTINCT user_id
			FROM analytics_events
			WHERE event_name = 'workout_completed'
		),
		user_groups AS (
			SELECT
				us.user_id,
				CASE
					WHEN cu.user_id IS NOT NULL THEN 'with_workout_completion'
					ELSE 'without_workout_completion'
				END AS group_name,
				us.active_days_last_7,
				us.active_days_last_30,
				us.sessions_count,
				us.workout_events_count,
				us.social_actions_count,
				us.error_events_count
			FROM analytics_user_summary us
			LEFT JOIN completed_users cu
				ON cu.user_id = us.user_id
		)
		SELECT
			group_name,
			COUNT(*) AS users_count,
			COALESCE(AVG(active_days_last_7::double precision), 0) AS average_active_days_last_7,
			COALESCE(AVG(active_days_last_30::double precision), 0) AS average_active_days_last_30,
			COALESCE(AVG(sessions_count::double precision), 0) AS average_sessions_count,
			COALESCE(AVG(workout_events_count::double precision), 0) AS average_workout_events,
			COALESCE(AVG(social_actions_count::double precision), 0) AS average_social_actions,
			COALESCE(AVG(error_events_count::double precision), 0) AS average_error_events
		FROM user_groups
		GROUP BY group_name
		ORDER BY group_name
	`)
	if err != nil {
		return nil, err
	}

	return &models.ResearchComparisonResponse{
		Title:  "Workout completion vs engagement",
		Groups: items,
	}, nil
}

func (s *AnalyticsStore) GetResearchErrorsVsDropoff(ctx context.Context) (*models.ResearchComparisonResponse, error) {
	items := []models.ResearchGroupMetrics{}

	err := s.db.SelectContext(ctx, &items, `
		WITH session_user_metrics AS (
			SELECT
				s.user_id,
				CASE
					WHEN s.has_error THEN 'sessions_with_errors'
					ELSE 'sessions_without_errors'
				END AS group_name,
				AVG(s.duration_seconds::double precision) AS avg_duration_seconds,
				AVG(s.events_count::double precision) AS avg_events_count,
				AVG(us.active_days_last_7::double precision) AS avg_active_days_last_7,
				AVG(us.active_days_last_30::double precision) AS avg_active_days_last_30,
				AVG(us.sessions_count::double precision) AS avg_sessions_count,
				AVG(us.workout_events_count::double precision) AS avg_workout_events_count,
				AVG(us.social_actions_count::double precision) AS avg_social_actions_count,
				AVG(us.error_events_count::double precision) AS avg_error_events_count,
				COUNT(DISTINCT s.user_id) AS users_count
			FROM analytics_sessions s
			LEFT JOIN analytics_user_summary us
				ON us.user_id = s.user_id
			GROUP BY
				s.user_id,
				CASE
					WHEN s.has_error THEN 'sessions_with_errors'
					ELSE 'sessions_without_errors'
				END
		)
		SELECT
			group_name,
			COALESCE(SUM(users_count), 0) AS users_count,
			COALESCE(AVG(avg_active_days_last_7), 0) AS average_active_days_last_7,
			COALESCE(AVG(avg_active_days_last_30), 0) AS average_active_days_last_30,
			COALESCE(AVG(avg_sessions_count), 0) AS average_sessions_count,
			COALESCE(AVG(avg_workout_events_count), 0) AS average_workout_events,
			COALESCE(AVG(avg_social_actions_count), 0) AS average_social_actions,
			COALESCE(AVG(avg_error_events_count), 0) AS average_error_events
		FROM session_user_metrics
		GROUP BY group_name
		ORDER BY group_name
	`)
	if err != nil {
		return nil, err
	}

	return &models.ResearchComparisonResponse{
		Title:  "Errors vs drop-off proxy",
		Groups: items,
	}, nil
}

func (s *AnalyticsStore) GetResearchFeatureRetention(ctx context.Context) (*models.ResearchFeatureRetentionResponse, error) {
	items := []models.ResearchFeatureRetentionItem{}

	err := s.db.SelectContext(ctx, &items, `
		WITH user_feature_flags AS (
			SELECT
				us.user_id,
				us.active_days_last_7,
				us.active_days_last_30,
				us.sessions_count,
				MAX(CASE WHEN ae.event_category = 'workout' THEN 1 ELSE 0 END) AS has_workout,
				MAX(CASE WHEN ae.event_category = 'social' THEN 1 ELSE 0 END) AS has_social,
				MAX(CASE WHEN ae.event_category = 'chat' THEN 1 ELSE 0 END) AS has_chat,
				MAX(CASE WHEN ae.event_category = 'calendar' THEN 1 ELSE 0 END) AS has_calendar,
				MAX(CASE WHEN ae.event_category = 'profile' THEN 1 ELSE 0 END) AS has_profile,
				MAX(CASE WHEN ae.event_category = 'settings' THEN 1 ELSE 0 END) AS has_settings,
				MAX(CASE WHEN ae.event_category = 'sharing' THEN 1 ELSE 0 END) AS has_sharing
			FROM analytics_user_summary us
			LEFT JOIN analytics_events ae
				ON ae.user_id = us.user_id
			GROUP BY
				us.user_id,
				us.active_days_last_7,
				us.active_days_last_30,
				us.sessions_count
		),
		feature_rows AS (
			SELECT 'workout' AS feature_name, user_id, active_days_last_7, active_days_last_30, sessions_count
			FROM user_feature_flags
			WHERE has_workout = 1

			UNION ALL
			SELECT 'social', user_id, active_days_last_7, active_days_last_30, sessions_count
			FROM user_feature_flags
			WHERE has_social = 1

			UNION ALL
			SELECT 'chat', user_id, active_days_last_7, active_days_last_30, sessions_count
			FROM user_feature_flags
			WHERE has_chat = 1

			UNION ALL
			SELECT 'calendar', user_id, active_days_last_7, active_days_last_30, sessions_count
			FROM user_feature_flags
			WHERE has_calendar = 1

			UNION ALL
			SELECT 'profile', user_id, active_days_last_7, active_days_last_30, sessions_count
			FROM user_feature_flags
			WHERE has_profile = 1

			UNION ALL
			SELECT 'settings', user_id, active_days_last_7, active_days_last_30, sessions_count
			FROM user_feature_flags
			WHERE has_settings = 1

			UNION ALL
			SELECT 'sharing', user_id, active_days_last_7, active_days_last_30, sessions_count
			FROM user_feature_flags
			WHERE has_sharing = 1
		)
		SELECT
			feature_name,
			COUNT(*) AS users_count,
			COALESCE(AVG(active_days_last_7::double precision), 0) AS average_active_days_last_7,
			COALESCE(AVG(active_days_last_30::double precision), 0) AS average_active_days_last_30,
			COALESCE(AVG(sessions_count::double precision), 0) AS average_sessions_count
		FROM feature_rows
		GROUP BY feature_name
		ORDER BY users_count DESC, feature_name ASC
	`)
	if err != nil {
		return nil, err
	}

	return &models.ResearchFeatureRetentionResponse{
		Title: "Feature groups vs engagement/retention proxy",
		Items: items,
	}, nil
}