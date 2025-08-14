{{ config(materialized='table') }}

WITH locs AS (
    SELECT pickup_latitude AS latitude, pickup_longitude AS longitude
    FROM {{ ref('silver_uber_trips') }}
    WHERE pickup_latitude IS NOT NULL
      AND pickup_longitude IS NOT NULL

    UNION

    SELECT dropoff_latitude, dropoff_longitude
    FROM {{ ref('silver_uber_trips') }}
    WHERE dropoff_latitude IS NOT NULL
      AND dropoff_longitude IS NOT NULL
)

SELECT
    ROW_NUMBER() OVER (ORDER BY latitude, longitude) AS location_id,
    latitude,
    longitude
FROM locs
