{{ config(materialized='table') }}

WITH src AS (
  SELECT DISTINCT vendor_id
  FROM {{ ref('silver_uber_trips') }}
  WHERE vendor_id IS NOT NULL
)

SELECT
  vendor_id,
  CASE vendor_id
    WHEN 1 THEN 'Uber App (Direct)'
    WHEN 2 THEN 'Partner Fleet Program'
    ELSE 'Unknown Vendor'
  END AS vendor_name
FROM src