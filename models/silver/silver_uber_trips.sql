{{ config(materialized='table') }}

WITH raw AS (
    SELECT *
    FROM {{ source('bronze', 'uber_raw') }}
),

cleaned AS (
    SELECT
        vendor_id,
        tpep_pickup_datetime  AS pickup_ts,
        tpep_dropoff_datetime AS dropoff_ts,
        passenger_count,
        trip_distance,
        ratecodeid     AS rate_code,
        store_and_fwd_flag,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        TIMESTAMPDIFF(minute, tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_duration_minutes,

        NULLIF(pickup_latitude,  0) AS pickup_latitude,
        NULLIF(pickup_longitude, 0) AS pickup_longitude,
        NULLIF(dropoff_latitude, 0) AS dropoff_latitude,
        NULLIF(dropoff_longitude,0) AS dropoff_longitude

    FROM raw
    WHERE trip_distance > 0
      AND passenger_count > 0
      AND fare_amount > 0
      AND tpep_dropoff_datetime > tpep_pickup_datetime
      AND pickup_latitude BETWEEN -90 AND 90
      AND pickup_longitude BETWEEN -180 AND 180
      AND dropoff_latitude BETWEEN -90 AND 90
      AND dropoff_longitude BETWEEN -180 AND 180
      AND NOT (pickup_latitude IS NULL AND pickup_longitude IS NULL)
      AND NOT (dropoff_latitude IS NULL AND dropoff_longitude IS NULL)
)

SELECT *
FROM cleaned