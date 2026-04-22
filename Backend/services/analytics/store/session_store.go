package store

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
)

func (s *AnalyticsStore) UpsertSessions(ctx context.Context, sessions []models.SessionSummary) error {
	if len(sessions) == 0 {
		return nil
	}

	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() {
		_ = tx.Rollback()
	}()

	for _, session := range sessions {
		_, err := tx.ExecContext(ctx, `
			INSERT INTO analytics_sessions (
				user_id,
				session_id,
				started_at,
				ended_at,
				duration_seconds,
				events_count,
				unique_screens_count,
				has_error,
				has_navigation_activity,
				has_workout_activity,
				has_social_activity,
				has_chat_activity,
				has_calendar_activity,
				has_profile_activity,
				has_settings_activity,
				has_sharing_activity,
				activity_type,
				platform,
				app_version,
				updated_at
			)
			VALUES (
				$1, $2, $3, $4, $5, $6, $7, $8,
				$9, $10, $11, $12, $13, $14, $15, $16,
				$17, $18, $19, NOW()
			)
			ON CONFLICT (user_id, session_id)
			DO UPDATE SET
				started_at = LEAST(analytics_sessions.started_at, EXCLUDED.started_at),
				ended_at = GREATEST(analytics_sessions.ended_at, EXCLUDED.ended_at),
				duration_seconds = EXTRACT(EPOCH FROM (GREATEST(analytics_sessions.ended_at, EXCLUDED.ended_at) - LEAST(analytics_sessions.started_at, EXCLUDED.started_at)))::BIGINT,
				events_count = analytics_sessions.events_count + EXCLUDED.events_count,
				unique_screens_count = GREATEST(analytics_sessions.unique_screens_count, EXCLUDED.unique_screens_count),
				has_error = analytics_sessions.has_error OR EXCLUDED.has_error,
				has_navigation_activity = analytics_sessions.has_navigation_activity OR EXCLUDED.has_navigation_activity,
				has_workout_activity = analytics_sessions.has_workout_activity OR EXCLUDED.has_workout_activity,
				has_social_activity = analytics_sessions.has_social_activity OR EXCLUDED.has_social_activity,
				has_chat_activity = analytics_sessions.has_chat_activity OR EXCLUDED.has_chat_activity,
				has_calendar_activity = analytics_sessions.has_calendar_activity OR EXCLUDED.has_calendar_activity,
				has_profile_activity = analytics_sessions.has_profile_activity OR EXCLUDED.has_profile_activity,
				has_settings_activity = analytics_sessions.has_settings_activity OR EXCLUDED.has_settings_activity,
				has_sharing_activity = analytics_sessions.has_sharing_activity OR EXCLUDED.has_sharing_activity,
				activity_type = CASE
					WHEN
						(CASE WHEN (analytics_sessions.has_workout_activity OR EXCLUDED.has_workout_activity) THEN 1 ELSE 0 END) +
						(CASE WHEN (analytics_sessions.has_social_activity OR EXCLUDED.has_social_activity) THEN 1 ELSE 0 END) +
						(CASE WHEN (analytics_sessions.has_chat_activity OR EXCLUDED.has_chat_activity) THEN 1 ELSE 0 END) +
						(CASE WHEN (analytics_sessions.has_calendar_activity OR EXCLUDED.has_calendar_activity) THEN 1 ELSE 0 END) +
						(CASE WHEN (analytics_sessions.has_profile_activity OR EXCLUDED.has_profile_activity) THEN 1 ELSE 0 END) +
						(CASE WHEN (analytics_sessions.has_settings_activity OR EXCLUDED.has_settings_activity) THEN 1 ELSE 0 END) +
						(CASE WHEN (analytics_sessions.has_sharing_activity OR EXCLUDED.has_sharing_activity) THEN 1 ELSE 0 END)
						> 1
					THEN 'mixed'

					WHEN (analytics_sessions.has_workout_activity OR EXCLUDED.has_workout_activity) THEN 'workout'
					WHEN (analytics_sessions.has_social_activity OR EXCLUDED.has_social_activity) THEN 'social'
					WHEN (analytics_sessions.has_chat_activity OR EXCLUDED.has_chat_activity) THEN 'chat'
					WHEN (analytics_sessions.has_calendar_activity OR EXCLUDED.has_calendar_activity) THEN 'calendar'
					WHEN (analytics_sessions.has_profile_activity OR EXCLUDED.has_profile_activity) THEN 'profile'
					WHEN (analytics_sessions.has_settings_activity OR EXCLUDED.has_settings_activity) THEN 'settings'
					WHEN (analytics_sessions.has_sharing_activity OR EXCLUDED.has_sharing_activity) THEN 'sharing'
					WHEN (analytics_sessions.has_navigation_activity OR EXCLUDED.has_navigation_activity) THEN 'navigation_only'
					ELSE 'unknown'
				END,
				platform = COALESCE(EXCLUDED.platform, analytics_sessions.platform),
				app_version = COALESCE(EXCLUDED.app_version, analytics_sessions.app_version),
				updated_at = NOW()
		`,
			session.UserID,
			session.SessionID,
			session.StartedAt,
			session.EndedAt,
			session.DurationSeconds,
			session.EventsCount,
			session.UniqueScreensCount,
			session.HasError,
			session.HasNavigationActivity,
			session.HasWorkoutActivity,
			session.HasSocialActivity,
			session.HasChatActivity,
			session.HasCalendarActivity,
			session.HasProfileActivity,
			session.HasSettingsActivity,
			session.HasSharingActivity,
			session.ActivityType,
			session.Platform,
			session.AppVersion,
		)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}