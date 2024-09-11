WITH adjusted_events AS (
  SELECT
    user_id,
    event_name,
    event_timestamp,
    TIMESTAMP_SECONDS(CAST(FLOOR(event_timestamp / 1000000) AS INT64)) AS event_time,
    LAG(TIMESTAMP_SECONDS(CAST(FLOOR(event_timestamp / 1000000) AS INT64))) OVER (PARTITION BY user_id ORDER BY TIMESTAMP_SECONDS(CAST(FLOOR(event_timestamp / 1000000) AS INT64))) AS prev_event_time
  FROM 
    `analytics_v2.clustered_events`
  WHERE 
    platform IN ('ios', 'android')
    AND event_timestamp IS NOT NULL
    AND user_id IS NOT NULL
),

session_boundaries AS (
  --30-minute gap
  SELECT
    user_id,
    event_name,
    event_time,
    event_timestamp,
    CASE
      WHEN prev_event_time IS NULL OR TIMESTAMP_DIFF(event_time, prev_event_time, MINUTE) > 30 THEN 1
      ELSE 0
    END AS new_session
  FROM 
    adjusted_events
),

sessions AS (
  
  SELECT
    user_id,
    event_name,
    event_time,
    event_timestamp,
    SUM(new_session) OVER (PARTITION BY user_id ORDER BY event_time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) + 1 AS session_number
  FROM 
    session_boundaries
)


SELECT
  user_id,
  event_name,
  event_timestamp,
  event_time,
  session_number
FROM 
  sessions
ORDER BY 
  user_id, session_number, event_time;
