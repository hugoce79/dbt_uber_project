{{ config(materialized='table') }}

WITH src AS (
  SELECT DISTINCT payment_type
  FROM {{ ref('silver_uber_trips') }}
  WHERE payment_type IS NOT NULL
)

SELECT
  payment_type AS payment_type_id,
  CASE payment_type
    WHEN 1 THEN 'Credit card'
    WHEN 2 THEN 'Cash'
    WHEN 3 THEN 'No charge'
    WHEN 4 THEN 'Dispute'
    WHEN 5 THEN 'Unknown'
    WHEN 6 THEN 'Voided trip'
    ELSE 'Other'
  END AS payment_type_desc
FROM src