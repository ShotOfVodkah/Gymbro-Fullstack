package store

import (
	"context"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/jmoiron/sqlx"
	"github.com/lib/pq"
)

func (s *AnalyticsStore) RebuildFunnelsForDates(ctx context.Context, dates []string) error {
	if len(dates) == 0 {
		return nil
	}

	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	_, err = tx.ExecContext(ctx, `
		DELETE FROM analytics_funnel_daily
		WHERE event_date::text = ANY($1)
		  AND funnel_name IN (
			'workout_share',
			'registration_to_first_workout',
			'feeds_open_to_interaction',
			'profile_open_to_relationship_action'
		  )
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	if err := s.insertWorkoutShareFunnel(ctx, tx, dates); err != nil {
		return err
	}
	if err := s.insertRegistrationToFirstWorkoutFunnel(ctx, tx, dates); err != nil {
		return err
	}
	if err := s.insertFeedsOpenToInteractionFunnel(ctx, tx, dates); err != nil {
		return err
	}
	if err := s.insertProfileOpenToRelationshipActionFunnel(ctx, tx, dates); err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AnalyticsStore) insertWorkoutShareFunnel(ctx context.Context, tx *sqlx.Tx, dates []string) error {
	_, err := tx.ExecContext(ctx, `
		WITH filtered_events AS (
			SELECT
				event_date,
				user_id,
				event_name
			FROM analytics_events
			WHERE event_date::text = ANY($1)
			  AND event_name IN (
				'workout_share_opened',
				'workout_share_step_viewed',
				'workout_share_step_next_tapped',
				'workout_share_submit_tapped',
				'workout_share_submit_succeeded',
				'workout_share_success_viewed',
				'workout_share_done_tapped'
			  )
			GROUP BY event_date, user_id, event_name
		),
		user_steps AS (
			SELECT
				event_date,
				user_id,
				BOOL_OR(event_name = 'workout_share_opened') AS has_step_1,
				BOOL_OR(event_name = 'workout_share_step_viewed') AS has_step_2,
				BOOL_OR(event_name = 'workout_share_step_next_tapped') AS has_step_3,
				BOOL_OR(event_name = 'workout_share_submit_tapped') AS has_step_4,
				BOOL_OR(event_name = 'workout_share_submit_succeeded') AS has_step_5,
				BOOL_OR(event_name = 'workout_share_success_viewed') AS has_step_6,
				BOOL_OR(event_name = 'workout_share_done_tapped') AS has_step_7
			FROM filtered_events
			GROUP BY event_date, user_id
		),
		funnel_counts AS (
			SELECT
				event_date,
				COUNT(*) FILTER (WHERE has_step_1) AS step_1_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2) AS step_2_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3) AS step_3_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3 AND has_step_4) AS step_4_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3 AND has_step_4 AND has_step_5) AS step_5_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3 AND has_step_4 AND has_step_5 AND has_step_6) AS step_6_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3 AND has_step_4 AND has_step_5 AND has_step_6 AND has_step_7) AS step_7_users
			FROM user_steps
			GROUP BY event_date
		),
		unpivot AS (
			SELECT event_date, 'workout_share'::TEXT AS funnel_name, 1 AS step_order, 'workout_share_opened'::TEXT AS step_name, step_1_users AS users_count, step_1_users AS prev_users, step_1_users AS start_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'workout_share', 2, 'workout_share_step_viewed', step_2_users, step_1_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'workout_share', 3, 'workout_share_step_next_tapped', step_3_users, step_2_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'workout_share', 4, 'workout_share_submit_tapped', step_4_users, step_3_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'workout_share', 5, 'workout_share_submit_succeeded', step_5_users, step_4_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'workout_share', 6, 'workout_share_success_viewed', step_6_users, step_5_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'workout_share', 7, 'workout_share_done_tapped', step_7_users, step_6_users, step_1_users FROM funnel_counts
		)
		INSERT INTO analytics_funnel_daily (
			event_date, funnel_name, step_order, step_name, users_count,
			conversion_from_prev, conversion_from_start, created_at, updated_at
		)
		SELECT
			event_date,
			funnel_name,
			step_order,
			step_name,
			users_count,
			CASE WHEN step_order = 1 THEN 1
			     WHEN prev_users > 0 THEN users_count::double precision / prev_users
			     ELSE 0 END,
			CASE WHEN start_users > 0 THEN users_count::double precision / start_users
			     ELSE 0 END,
			NOW(),
			NOW()
		FROM unpivot
		ORDER BY event_date, step_order
	`, pq.Array(dates))
	return err
}

func (s *AnalyticsStore) insertRegistrationToFirstWorkoutFunnel(ctx context.Context, tx *sqlx.Tx, dates []string) error {
	_, err := tx.ExecContext(ctx, `
		WITH filtered_events AS (
			SELECT
				event_date,
				user_id,
				event_name
			FROM analytics_events
			WHERE event_date::text = ANY($1)
			  AND event_name IN (
				'user_registered',
				'user_logged_in',
				'workout_created',
				'workout_completed'
			  )
			GROUP BY event_date, user_id, event_name
		),
		user_steps AS (
			SELECT
				event_date,
				user_id,
				BOOL_OR(event_name = 'user_registered') AS has_step_1,
				BOOL_OR(event_name = 'user_logged_in') AS has_step_2,
				BOOL_OR(event_name = 'workout_created') AS has_step_3,
				BOOL_OR(event_name = 'workout_completed') AS has_step_4
			FROM filtered_events
			GROUP BY event_date, user_id
		),
		funnel_counts AS (
			SELECT
				event_date,
				COUNT(*) FILTER (WHERE has_step_1) AS step_1_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2) AS step_2_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3) AS step_3_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3 AND has_step_4) AS step_4_users
			FROM user_steps
			GROUP BY event_date
		),
		unpivot AS (
			SELECT event_date, 'registration_to_first_workout'::TEXT AS funnel_name, 1 AS step_order, 'user_registered'::TEXT AS step_name, step_1_users AS users_count, step_1_users AS prev_users, step_1_users AS start_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'registration_to_first_workout', 2, 'user_logged_in', step_2_users, step_1_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'registration_to_first_workout', 3, 'workout_created', step_3_users, step_2_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'registration_to_first_workout', 4, 'workout_completed', step_4_users, step_3_users, step_1_users FROM funnel_counts
		)
		INSERT INTO analytics_funnel_daily (
			event_date, funnel_name, step_order, step_name, users_count,
			conversion_from_prev, conversion_from_start, created_at, updated_at
		)
		SELECT
			event_date,
			funnel_name,
			step_order,
			step_name,
			users_count,
			CASE WHEN step_order = 1 THEN 1
			     WHEN prev_users > 0 THEN users_count::double precision / prev_users
			     ELSE 0 END,
			CASE WHEN start_users > 0 THEN users_count::double precision / start_users
			     ELSE 0 END,
			NOW(),
			NOW()
		FROM unpivot
		ORDER BY event_date, step_order
	`, pq.Array(dates))
	return err
}

func (s *AnalyticsStore) insertFeedsOpenToInteractionFunnel(ctx context.Context, tx *sqlx.Tx, dates []string) error {
	_, err := tx.ExecContext(ctx, `
		WITH filtered_events AS (
			SELECT
				event_date,
				user_id,
				event_name,
				properties->>'screen' AS prop_screen
			FROM analytics_events
			WHERE event_date::text = ANY($1)
			  AND (
				(event_name = 'screen_viewed' AND properties->>'screen' = 'feedsMain')
				OR event_name IN (
					'feeds_post_author_tapped',
					'feeds_post_liked',
					'feeds_post_comment_tapped',
					'feeds_post_exercise_tapped',
					'feeds_post_show_all_exercises'
				)
			  )
			GROUP BY event_date, user_id, event_name, properties->>'screen'
		),
		user_steps AS (
			SELECT
				event_date,
				user_id,
				BOOL_OR(event_name = 'screen_viewed' AND prop_screen = 'feedsMain') AS has_step_1,
				BOOL_OR(event_name = 'feeds_post_author_tapped') AS has_step_2,
				BOOL_OR(event_name = 'feeds_post_liked') AS has_step_3,
				BOOL_OR(event_name = 'feeds_post_comment_tapped') AS has_step_4
			FROM filtered_events
			GROUP BY event_date, user_id
		),
		funnel_counts AS (
			SELECT
				event_date,
				COUNT(*) FILTER (WHERE has_step_1) AS step_1_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2) AS step_2_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3) AS step_3_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3 AND has_step_4) AS step_4_users
			FROM user_steps
			GROUP BY event_date
		),
		unpivot AS (
			SELECT event_date, 'feeds_open_to_interaction'::TEXT AS funnel_name, 1 AS step_order, 'feeds_opened'::TEXT AS step_name, step_1_users AS users_count, step_1_users AS prev_users, step_1_users AS start_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'feeds_open_to_interaction', 2, 'feeds_post_author_tapped', step_2_users, step_1_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'feeds_open_to_interaction', 3, 'feeds_post_liked', step_3_users, step_2_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'feeds_open_to_interaction', 4, 'feeds_post_comment_tapped', step_4_users, step_3_users, step_1_users FROM funnel_counts
		)
		INSERT INTO analytics_funnel_daily (
			event_date, funnel_name, step_order, step_name, users_count,
			conversion_from_prev, conversion_from_start, created_at, updated_at
		)
		SELECT
			event_date,
			funnel_name,
			step_order,
			step_name,
			users_count,
			CASE WHEN step_order = 1 THEN 1
			     WHEN prev_users > 0 THEN users_count::double precision / prev_users
			     ELSE 0 END,
			CASE WHEN start_users > 0 THEN users_count::double precision / start_users
			     ELSE 0 END,
			NOW(),
			NOW()
		FROM unpivot
		ORDER BY event_date, step_order
	`, pq.Array(dates))
	return err
}

func (s *AnalyticsStore) insertProfileOpenToRelationshipActionFunnel(ctx context.Context, tx *sqlx.Tx, dates []string) error {
	_, err := tx.ExecContext(ctx, `
		WITH filtered_events AS (
			SELECT
				event_date,
				user_id,
				event_name,
				properties->>'screen' AS prop_screen
			FROM analytics_events
			WHERE event_date::text = ANY($1)
			  AND (
				(event_name = 'screen_viewed' AND properties->>'screen' = 'profile')
				OR event_name IN (
					'profile_relationship_follow_tapped',
					'profile_relationship_message_tapped',
					'profile_relationship_posts_tapped'
				)
			  )
			GROUP BY event_date, user_id, event_name, properties->>'screen'
		),
		user_steps AS (
			SELECT
				event_date,
				user_id,
				BOOL_OR(event_name = 'screen_viewed' AND prop_screen = 'profile') AS has_step_1,
				BOOL_OR(event_name = 'profile_relationship_follow_tapped') AS has_step_2,
				BOOL_OR(event_name = 'profile_relationship_message_tapped') AS has_step_3,
				BOOL_OR(event_name = 'profile_relationship_posts_tapped') AS has_step_4
			FROM filtered_events
			GROUP BY event_date, user_id
		),
		funnel_counts AS (
			SELECT
				event_date,
				COUNT(*) FILTER (WHERE has_step_1) AS step_1_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2) AS step_2_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3) AS step_3_users,
				COUNT(*) FILTER (WHERE has_step_1 AND has_step_2 AND has_step_3 AND has_step_4) AS step_4_users
			FROM user_steps
			GROUP BY event_date
		),
		unpivot AS (
			SELECT event_date, 'profile_open_to_relationship_action'::TEXT AS funnel_name, 1 AS step_order, 'profile_opened'::TEXT AS step_name, step_1_users AS users_count, step_1_users AS prev_users, step_1_users AS start_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'profile_open_to_relationship_action', 2, 'profile_relationship_follow_tapped', step_2_users, step_1_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'profile_open_to_relationship_action', 3, 'profile_relationship_message_tapped', step_3_users, step_2_users, step_1_users FROM funnel_counts
			UNION ALL
			SELECT event_date, 'profile_open_to_relationship_action', 4, 'profile_relationship_posts_tapped', step_4_users, step_3_users, step_1_users FROM funnel_counts
		)
		INSERT INTO analytics_funnel_daily (
			event_date, funnel_name, step_order, step_name, users_count,
			conversion_from_prev, conversion_from_start, created_at, updated_at
		)
		SELECT
			event_date,
			funnel_name,
			step_order,
			step_name,
			users_count,
			CASE WHEN step_order = 1 THEN 1
			     WHEN prev_users > 0 THEN users_count::double precision / prev_users
			     ELSE 0 END,
			CASE WHEN start_users > 0 THEN users_count::double precision / start_users
			     ELSE 0 END,
			NOW(),
			NOW()
		FROM unpivot
		ORDER BY event_date, step_order
	`, pq.Array(dates))
	return err
}

func (s *AnalyticsStore) GetLatestWorkoutShareFunnel(ctx context.Context) ([]models.FunnelDailyItem, error) {
	items := []models.FunnelDailyItem{}
	err := s.db.SelectContext(ctx, &items, `
		SELECT
			event_date::text AS event_date,
			funnel_name,
			step_order,
			step_name,
			users_count,
			conversion_from_prev,
			conversion_from_start
		FROM analytics_funnel_daily
		WHERE funnel_name = 'workout_share'
		  AND event_date = (
			  SELECT MAX(event_date)
			  FROM analytics_funnel_daily
			  WHERE funnel_name = 'workout_share'
		  )
		ORDER BY step_order
	`)
	if err != nil {
		return nil, err
	}
	return items, nil
}

func (s *AnalyticsStore) GetLatestFunnel(ctx context.Context, funnelName string) ([]models.FunnelDailyItem, error) {
	items := []models.FunnelDailyItem{}
	err := s.db.SelectContext(ctx, &items, `
		SELECT
			event_date::text AS event_date,
			funnel_name,
			step_order,
			step_name,
			users_count,
			conversion_from_prev,
			conversion_from_start
		FROM analytics_funnel_daily
		WHERE funnel_name = $1
		  AND event_date = (
			  SELECT MAX(event_date)
			  FROM analytics_funnel_daily
			  WHERE funnel_name = $1
		  )
		ORDER BY step_order
	`, funnelName)
	if err != nil {
		return nil, err
	}
	return items, nil
}