-- +goose Up

CREATE TABLE IF NOT EXISTS analytics_retention_cohorts (
    id BIGSERIAL PRIMARY KEY,
    cohort_date DATE NOT NULL,
    cohort_size INT NOT NULL DEFAULT 0,

    retained_d1 INT NOT NULL DEFAULT 0,
    retained_d7 INT NOT NULL DEFAULT 0,
    retained_d14 INT NOT NULL DEFAULT 0,
    retained_d30 INT NOT NULL DEFAULT 0,

    retention_d1 DOUBLE PRECISION NOT NULL DEFAULT 0,
    retention_d7 DOUBLE PRECISION NOT NULL DEFAULT 0,
    retention_d14 DOUBLE PRECISION NOT NULL DEFAULT 0,
    retention_d30 DOUBLE PRECISION NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_analytics_retention_cohorts UNIQUE (cohort_date)
);

CREATE INDEX IF NOT EXISTS idx_analytics_retention_cohorts_cohort_date
    ON analytics_retention_cohorts(cohort_date);

-- +goose Down

DROP INDEX IF EXISTS idx_analytics_retention_cohorts_cohort_date;
DROP TABLE IF EXISTS analytics_retention_cohorts;