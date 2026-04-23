-- +goose Up

CREATE MATERIALIZED VIEW IF NOT EXISTS analytics_dashboard_overview_mv AS
SELECT
    p.event_date,
    p.batches_received,
    p.events_received,
    p.events_accepted,
    p.events_rejected,
    p.backlog_pending,
    p.backlog_processing,
    p.backlog_failed,
    p.avg_processing_lag_seconds,
    p.max_processing_lag_seconds,
    p.processing_failures,
    COALESCE(dau.dau, 0) AS dau,
    COALESCE(err.total_errors, 0) AS total_errors,
    COALESCE(dq.invalid_rate, 0) AS invalid_rate
FROM analytics_pipeline_daily p
LEFT JOIN analytics_daily_active_users dau
    ON dau.event_date = p.event_date
LEFT JOIN (
    SELECT
        event_date,
        SUM(error_count) AS total_errors
    FROM analytics_error_daily
    GROUP BY event_date
) err
    ON err.event_date = p.event_date
LEFT JOIN (
    SELECT
        event_date,
        CASE
            WHEN SUM(events_received) > 0
            THEN SUM(events_rejected)::double precision / SUM(events_received)
            ELSE 0
        END AS invalid_rate
    FROM analytics_data_quality_daily
    GROUP BY event_date
) dq
    ON dq.event_date = p.event_date;

CREATE UNIQUE INDEX IF NOT EXISTS idx_analytics_dashboard_overview_mv_event_date
    ON analytics_dashboard_overview_mv(event_date);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_dashboard_overview_mv_event_date;
DROP MATERIALIZED VIEW IF EXISTS analytics_dashboard_overview_mv;