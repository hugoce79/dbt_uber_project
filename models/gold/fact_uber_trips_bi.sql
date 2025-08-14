{{ config(materialized='view') }}

SELECT
    f.trip_id,

    f.vendor_id,
    v.vendor_name,

    f.payment_type_id,
    pt.payment_type_desc,

    f.rate_code_id,
    rc.rate_code_desc,

    f.pickup_datetime_id,
    dpt.datetime AS pickup_datetime,

    f.dropoff_datetime_id,
    ddt.datetime AS dropoff_datetime,

    f.pickup_location_id,
    pl.latitude  AS pickup_latitude,
    pl.longitude AS pickup_longitude,

    f.dropoff_location_id,
    dl.latitude  AS dropoff_latitude,
    dl.longitude AS dropoff_longitude,

    f.passenger_count,
    f.trip_distance,
    f.fare_amount,
    f.tip_amount,
    f.total_amount,
    f.trip_duration_minutes

FROM {{ ref('fact_uber_trips') }} f
LEFT JOIN {{ ref('dim_time') }}         dpt ON f.pickup_datetime_id  = dpt.datetime_id
LEFT JOIN {{ ref('dim_time') }}         ddt ON f.dropoff_datetime_id = ddt.datetime_id
LEFT JOIN {{ ref('dim_vendor') }}       v   ON f.vendor_id           = v.vendor_id
LEFT JOIN {{ ref('dim_payment_type') }} pt  ON f.payment_type_id     = pt.payment_type_id
LEFT JOIN {{ ref('dim_rate_code') }}    rc  ON f.rate_code_id        = rc.rate_code_id
LEFT JOIN {{ ref('dim_location') }}     pl  ON f.pickup_location_id  = pl.location_id
LEFT JOIN {{ ref('dim_location') }}     dl  ON f.dropoff_location_id = dl.location_id