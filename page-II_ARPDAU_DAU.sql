SELECT 
    event_date,
    platform,
    COUNT(DISTINCT user_id) AS DAU,  -- Counting distinct daily active users
    SUM(ad_revenue) AS total_revenue,  --the ad revenue for each day
    CASE 
        WHEN COUNT(DISTINCT user_id) > 0 THEN SUM(ad_revenue) / COUNT(DISTINCT user_id)
        ELSE 0
    END AS ARPDAU  -- Calculating ARPDAU
FROM 
    `analytics_v2.clustered_events`
WHERE 
    platform IN ('android', 'ios')  -- Filtering for Android and iOS
    AND country = 'us'              -- Filtering for the US
    AND event_name = "AdImpressionRevenue"  -- Only include ad impression events to get revenue
GROUP BY 
    event_date,
    platform
ORDER BY 
    event_date, 
    platform;
