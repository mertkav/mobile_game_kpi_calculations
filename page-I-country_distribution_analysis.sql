WITH revenue_by_days AS (
    SELECT 
        platform, 
        country, 
        ad_type, 
        ad_revenue,
        user_id,  
        TIMESTAMP_DIFF(TIMESTAMP(event_date), TIMESTAMP(installed_datetime), DAY) AS days_after_install
    FROM 
        `analytics_v2.clustered_events`
    WHERE 
        event_name = "AdImpressionRevenue"
        AND platform IS NOT NULL
        AND country IS NOT NULL
        AND ad_type IS NOT NULL
)

SELECT 
    platform, 
    country, 
    ad_type, 
    COUNT(DISTINCT user_id) AS total_users,
    SUM(CASE WHEN days_after_install = 0 THEN ad_revenue ELSE 0 END) AS D0_revenue,
    SUM(CASE WHEN days_after_install <= 1 THEN ad_revenue ELSE 0 END) AS D1_revenue,
    SUM(CASE WHEN days_after_install <= 3 THEN ad_revenue ELSE 0 END) AS D3_revenue,
    SUM(CASE WHEN days_after_install <= 7 THEN ad_revenue ELSE 0 END) AS D7_revenue,
    SUM(CASE WHEN days_after_install <= 14 THEN ad_revenue ELSE 0 END) AS D14_revenue,
    SUM(CASE WHEN days_after_install <= 28 THEN ad_revenue ELSE 0 END) AS D28_revenue,
    SUM(ad_revenue) AS total_revenue,
    
    CASE 
        WHEN COUNT(DISTINCT user_id) > 0 THEN SUM(ad_revenue) / COUNT(DISTINCT user_id)
        ELSE 0
    END AS ARPU
FROM 
    revenue_by_days
GROUP BY 
    platform, 
    country, 
    ad_type;
