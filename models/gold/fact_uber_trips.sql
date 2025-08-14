{{ config(materialized='table') }}

WITH source AS ( 
  SELECT
    vendor_id,
    passenger_count,
    trip_distance,
    fare_amount,
    tip_amount,
    total_amount,
    trip_duration_minutes,
    payment_type   AS payment_type_id,
    rate_code      AS rate_code_id,
    pickup_ts,
    dropoff_ts,
    pickup_latitude,
    pickup_longitude,
    dropoff_latitude,
    dropoff_longitude
  FROM {{ ref('silver_uber_trips') }}
),
pickup_time_dim AS (
  SELECT datetime_id, datetime FROM {{ ref('dim_time') }}
),
dropoff_time_dim AS (
  SELECT datetime_id, datetime FROM {{ ref('dim_time') }}
),
pickup_location_dim AS (
  SELECT location_id, latitude, longitude FROM {{ ref('dim_location') }}
),
dropoff_location_dim AS (
  SELECT location_id, latitude, longitude FROM {{ ref('dim_location') }}
)

SELECT
  ROW_NUMBER() OVER (ORDER BY s.pickup_ts) AS trip_id,
  s.vendor_id,
  s.passenger_count,
  s.trip_distance,
  s.fare_amount,
  s.tip_amount,
  s.total_amount,
  s.trip_duration_minutes,
  s.payment_type_id,
  s.rate_code_id,
  pt.datetime_id AS pickup_datetime_id,
  dt.datetime_id AS dropoff_datetime_id,
  pl.location_id AS pickup_location_id,
  dl.location_id AS dropoff_location_id
FROM source s
LEFT JOIN pickup_time_dim  pt ON s.pickup_ts   = pt.datetime
LEFT JOIN dropoff_time_dim dt ON s.dropoff_ts  = dt.datetime
LEFT JOIN pickup_location_dim  pl
  ON s.pickup_latitude  = pl.latitude
 AND s.pickup_longitude = pl.longitude
LEFT JOIN dropoff_location_dim dl
  ON s.dropoff_latitude  = dl.latitude
 AND s.dropoff_longitude = dl.longitude
