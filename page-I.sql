-- ad revenue for different platforms, countries, and ad types.
-- segmented by days after installation (D0, D1, D3, D7, D14, D28).

WITH revenue_by_days AS (
    SELECT 
        platform, 
        country, 
        ad_type, 
        ad_revenue,
        event_date,
        installed_datetime,
       
        TIMESTAMP_DIFF(TIMESTAMP(event_date), TIMESTAMP(installed_datetime), DAY) AS days_after_install
    FROM 
        `analytics_v2.clustered_events`
    WHERE 
        event_name = "AdImpressionRevenue"
        AND platform IS NOT NULL
        AND country IS NOT NULL
        AND ad_type IS NOT NULL
)

-- Calculate ad revenue for each day window  and total revenue
SELECT 
    platform, 
    country, 
    ad_type, 
    SUM(CASE WHEN days_after_install = 0 THEN ad_revenue ELSE 0 END) AS D0_revenue,
    SUM(CASE WHEN days_after_install <= 1 THEN ad_revenue ELSE 0 END) AS D1_revenue,
    SUM(CASE WHEN days_after_install <= 3 THEN ad_revenue ELSE 0 END) AS D3_revenue,
    SUM(CASE WHEN days_after_install <= 7 THEN ad_revenue ELSE 0 END) AS D7_revenue,
    SUM(CASE WHEN days_after_install <= 14 THEN ad_revenue ELSE 0 END) AS D14_revenue,
    SUM(CASE WHEN days_after_install <= 28 THEN ad_revenue ELSE 0 END) AS D28_revenue,
    SUM(ad_revenue) AS total_revenue
FROM 
    revenue_by_days
GROUP BY 
    platform, 
    country, 
    ad_type;
