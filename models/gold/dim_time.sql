{{ config(materialized='table') }}

WITH pickup_times AS (
  SELECT DISTINCT pickup_ts AS datetime FROM {{ ref('silver_uber_trips') }}
),
dropoff_times AS (
  SELECT DISTINCT dropoff_ts AS datetime FROM {{ ref('silver_uber_trips') }}
),
all_times AS (
  SELECT datetime FROM pickup_times
  UNION
  SELECT datetime FROM dropoff_times
)

SELECT
  ROW_NUMBER() OVER (ORDER BY datetime) AS datetime_id,
  datetime,
  CAST(datetime AS DATE) AS date,
  EXTRACT(year  FROM datetime) AS year,
  EXTRACT(month FROM datetime) AS month,
  EXTRACT(day   FROM datetime) AS day,
  TO_VARCHAR(datetime, 'DY')   AS weekday,
  EXTRACT(hour  FROM datetime) AS hour
FROM all_times