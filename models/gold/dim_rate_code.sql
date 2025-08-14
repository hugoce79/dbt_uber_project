{{ config(materialized='table') }}

WITH src AS (
  SELECT DISTINCT rate_code
  FROM {{ ref('silver_uber_trips') }}
  WHERE rate_code IS NOT NULL
)

SELECT
  rate_code AS rate_code_id,
  CASE rate_code
    WHEN 1 THEN 'Standard rate'
    WHEN 2 THEN 'JFK'
    WHEN 3 THEN 'Newark'
    WHEN 4 THEN 'Nassau/Westchester'
    WHEN 5 THEN 'Negotiated fare'
    WHEN 6 THEN 'Group ride'
    ELSE 'Unknown'
  END AS rate_code_desc
FROM src