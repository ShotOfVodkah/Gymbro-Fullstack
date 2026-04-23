package store

import (
	"context"
	"database/sql"

	"github.com/alexandra-gritsaenko/gymbro-analytics/models"
	"github.com/lib/pq"
)

func (s *AnalyticsStore) RebuildDataQualityDailyForDates(ctx context.Context, dates []string) error {
	if len(dates) == 0 {
		return nil
	}

	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()

	_, err = tx.ExecContext(ctx, `
		DELETE FROM analytics_data_quality_daily
		WHERE event_date::text = ANY($1)
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, `
		WITH batch_received AS (
			SELECT
				received_at::date AS event_date,
				COALESCE(app_version, 'unknown') AS app_version,
				COALESCE(SUM(events_count), 0) AS events_received
			FROM analytics_event_batches
			WHERE received_at::date::text = ANY($1)
			GROUP BY received_at::date, COALESCE(app_version, 'unknown')
		),
		accepted AS (
			SELECT
				server_received_at::date AS event_date,
				COALESCE(app_version, 'unknown') AS app_version,
				COUNT(*) AS events_accepted
			FROM analytics_events
			WHERE server_received_at::date::text = ANY($1)
			GROUP BY server_received_at::date, COALESCE(app_version, 'unknown')
		),
		rejected AS (
			SELECT
				ieb.received_at::date AS event_date,
				COALESCE(ieb.app_version, 'unknown') AS app_version,
				COUNT(*) AS events_rejected,
				COUNT(*) FILTER (WHERE aie.reason = 'event_name is not allowed') AS unknown_events_count,
				COUNT(*) FILTER (WHERE aie.reason LIKE 'required property missing:%') AS missing_required_fields_count
			FROM analytics_invalid_events aie
			LEFT JOIN analytics_event_batches ieb
				ON ieb.batch_id = aie.batch_id
			WHERE ieb.received_at::date::text = ANY($1)
			GROUP BY ieb.received_at::date, COALESCE(ieb.app_version, 'unknown')
		),
		all_keys AS (
			SELECT event_date, app_version FROM batch_received
			UNION
			SELECT event_date, app_version FROM accepted
			UNION
			SELECT event_date, app_version FROM rejected
		)
		INSERT INTO analytics_data_quality_daily (
			event_date,
			app_version,
			events_received,
			events_accepted,
			events_rejected,
			invalid_rate,
			unknown_events_count,
			unknown_events_rate,
			missing_required_fields_count,
			created_at,
			updated_at
		)
		SELECT
			k.event_date,
			k.app_version,
			COALESCE(br.events_received, 0),
			COALESCE(a.events_accepted, 0),
			COALESCE(r.events_rejected, 0),
			CASE
				WHEN COALESCE(br.events_received, 0) > 0
				THEN COALESCE(r.events_rejected, 0)::double precision / br.events_received
				ELSE 0
			END,
			COALESCE(r.unknown_events_count, 0),
			CASE
				WHEN COALESCE(br.events_received, 0) > 0
				THEN COALESCE(r.unknown_events_count, 0)::double precision / br.events_received
				ELSE 0
			END,
			COALESCE(r.missing_required_fields_count, 0),
			NOW(),
			NOW()
		FROM all_keys k
		LEFT JOIN batch_received br
			ON br.event_date = k.event_date
		   AND br.app_version = k.app_version
		LEFT JOIN accepted a
			ON a.event_date = k.event_date
		   AND a.app_version = k.app_version
		LEFT JOIN rejected r
			ON r.event_date = k.event_date
		   AND r.app_version = k.app_version
		ORDER BY k.event_date, k.app_version
	`, pq.Array(dates))
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AnalyticsStore) GetDataQualityOverview(ctx context.Context) (*models.DataQualityOverviewItem, error) {
	var item models.DataQualityOverviewItem

	err := s.db.GetContext(ctx, &item, `
		SELECT
			event_date::text AS event_date,
			COALESCE(SUM(events_received), 0) AS events_received,
			COALESCE(SUM(events_accepted), 0) AS events_accepted,
			COALESCE(SUM(events_rejected), 0) AS events_rejected,
			CASE
				WHEN COALESCE(SUM(events_received), 0) > 0
				THEN COALESCE(SUM(events_rejected), 0)::double precision / SUM(events_received)
				ELSE 0
			END AS invalid_rate,
			COALESCE(SUM(unknown_events_count), 0) AS unknown_events_count,
			CASE
				WHEN COALESCE(SUM(events_received), 0) > 0
				THEN COALESCE(SUM(unknown_events_count), 0)::double precision / SUM(events_received)
				ELSE 0
			END AS unknown_events_rate,
			COALESCE(SUM(missing_required_fields_count), 0) AS missing_required_fields_count
		FROM analytics_data_quality_daily
		WHERE event_date = (SELECT MAX(event_date) FROM analytics_data_quality_daily)
		GROUP BY event_date
	`)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &item, nil
}

func (s *AnalyticsStore) GetDataQualityByAppVersion(ctx context.Context) ([]models.DataQualityDailyItem, error) {
	items := []models.DataQualityDailyItem{}

	err := s.db.SelectContext(ctx, &items, `
		SELECT
			event_date::text AS event_date,
			app_version,
			events_received,
			events_accepted,
			events_rejected,
			invalid_rate,
			unknown_events_count,
			unknown_events_rate,
			missing_required_fields_count
		FROM analytics_data_quality_daily
		WHERE event_date = (SELECT MAX(event_date) FROM analytics_data_quality_daily)
		ORDER BY invalid_rate DESC, events_rejected DESC, app_version ASC
	`)
	if err != nil {
		return nil, err
	}

	return items, nil
}