-- sql/00_setup.sql  (safe to re-run)
CREATE CATALOG IF NOT EXISTS hr_analytics COMMENT 'Tulip Industries HR lakehouse';
USE CATALOG hr_analytics;

CREATE SCHEMA IF NOT EXISTS landing    COMMENT 'Raw files only (volumes)';
CREATE SCHEMA IF NOT EXISTS hris_src   COMMENT 'Simulated HR source system and its fault log. Not part of the warehouse';
CREATE SCHEMA IF NOT EXISTS bronze     COMMENT 'Raw data as received + load metadata';
CREATE SCHEMA IF NOT EXISTS silver     COMMENT 'dbt staging + intermediate: cleaned, typed, deduplicated';
CREATE SCHEMA IF NOT EXISTS snapshots  COMMENT 'dbt snapshots (SCD2 history)';
CREATE SCHEMA IF NOT EXISTS gold       COMMENT 'dbt marts: star schema for reporting';
CREATE SCHEMA IF NOT EXISTS restricted COMMENT 'Personal data. HR admins only';
CREATE SCHEMA IF NOT EXISTS ops        COMMENT 'Pipeline audit and control tables';

CREATE VOLUME IF NOT EXISTS landing.raw         COMMENT 'Landing zone for files';
CREATE VOLUME IF NOT EXISTS landing.checkpoints COMMENT 'Auto Loader checkpoints and schemas';

CREATE TABLE IF NOT EXISTS ops.pipeline_runs (
  run_id        STRING,
  step          STRING,
  business_date DATE,
  rows_written  BIGINT,
  status        STRING,
  started_at    TIMESTAMP,
  finished_at   TIMESTAMP
);

-- Access: analysts read gold only, admins also read restricted
GRANT USE CATALOG ON CATALOG hr_analytics TO `hr_analysts`;
GRANT USE SCHEMA, SELECT ON SCHEMA hr_analytics.gold TO `hr_analysts`;

GRANT USE CATALOG ON CATALOG hr_analytics TO `hr_admins`;
GRANT USE SCHEMA, SELECT ON SCHEMA hr_analytics.restricted TO `hr_admins`;