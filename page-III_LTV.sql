WITH installs AS (
    SELECT 
        user_id,
        platform,
        country,
        DATE(installed_datetime) AS install_date
    FROM 
        `analytics_v2.clustered_events`
    WHERE 
        platform IN ('android', 'ios')  
        AND country = 'us'  
        AND event_name IN ('level_start', 'GameStart', 'InitialGameStart')
),

retention_by_day AS (

    SELECT 
        i.platform,
        i.country,
        COUNT(DISTINCT CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 0 DAY) THEN e.user_id END) AS D0_users,
        
        -- Calculate retention for Day 1 
        COUNT(DISTINCT CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 1 DAY) THEN e.user_id END) AS D1_retained,  
        
        -- Calculate retention for Day 3 
        COUNT(DISTINCT CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 3 DAY) THEN e.user_id END) AS D3_retained,
        
        -- Calculate retention for Day 7
        COUNT(DISTINCT CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 7 DAY) THEN e.user_id END) AS D7_retained,
        
        -- Calculate retention for Day 14
        COUNT(DISTINCT CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 14 DAY) THEN e.user_id END) AS D14_retained,
        
        -- Calculate retention for Day 28
        COUNT(DISTINCT CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 28 DAY) THEN e.user_id END) AS D28_retained  
    FROM 
        installs i
    LEFT JOIN 
        `analytics_v2.clustered_events` e 
        ON i.user_id = e.user_id
    GROUP BY 
        i.platform, i.country
),

-- ARPU for each platform and country
arpu_by_platform_country AS (
    SELECT 
        platform,
        country,
        SUM(ad_revenue) / COUNT(DISTINCT user_id) AS ARPU  
    FROM 
        `analytics_v2.clustered_events`
    WHERE 
        event_name = 'AdImpressionRevenue'
        AND platform IN ('android', 'ios')
        AND country = 'us'
    GROUP BY 
        platform, country
)

-- LTV
SELECT 
    rbd.platform,
    rbd.country,
    rbd.D0_users,

    -- Retention rates
    CASE WHEN rbd.D0_users > 0 THEN rbd.D1_retained / rbd.D0_users ELSE 0 END AS R_1,
    CASE WHEN rbd.D0_users > 0 THEN rbd.D3_retained / rbd.D0_users ELSE 0 END AS R_3,
    CASE WHEN rbd.D0_users > 0 THEN rbd.D7_retained / rbd.D0_users ELSE 0 END AS R_7,
    CASE WHEN rbd.D0_users > 0 THEN rbd.D14_retained / rbd.D0_users ELSE 0 END AS R_14,
    CASE WHEN rbd.D0_users > 0 THEN rbd.D28_retained / rbd.D0_users ELSE 0 END AS R_28,

  
    abpc.ARPU,

    -- LTV clac
    CASE 
        WHEN rbd.D0_users > 0 THEN abpc.ARPU * (rbd.D1_retained / rbd.D0_users)
        ELSE 0
    END AS LTV_1,

    -- Cumulative LTV_3 = LTV_1 + LTV_3
    CASE 
        WHEN rbd.D0_users > 0 THEN abpc.ARPU * ((rbd.D1_retained / rbd.D0_users) + (rbd.D3_retained / rbd.D0_users))
        ELSE 0
    END AS LTV_3,

    -- Cumulative LTV_7 = LTV_1 + LTV_3 + LTV_7
    CASE 
        WHEN rbd.D0_users > 0 THEN abpc.ARPU * ((rbd.D1_retained / rbd.D0_users) + (rbd.D3_retained / rbd.D0_users) + (rbd.D7_retained / rbd.D0_users))
        ELSE 0
    END AS LTV_7,

    -- Cumulative LTV_14 = LTV_1 + LTV_3 + LTV_7 + LTV_14
    CASE 
        WHEN rbd.D0_users > 0 THEN abpc.ARPU * ((rbd.D1_retained / rbd.D0_users) + (rbd.D3_retained / rbd.D0_users) + (rbd.D7_retained / rbd.D0_users) + (rbd.D14_retained / rbd.D0_users))
        ELSE 0
    END AS LTV_14,

    -- Cumulative LTV_28 = LTV_1 + LTV_3 + LTV_7 + LTV_14 + LTV_28
    CASE 
        WHEN rbd.D0_users > 0 THEN abpc.ARPU * ((rbd.D1_retained / rbd.D0_users) + (rbd.D3_retained / rbd.D0_users) + (rbd.D7_retained / rbd.D0_users) + (rbd.D14_retained / rbd.D0_users) + (rbd.D28_retained / rbd.D0_users))
        ELSE 0
    END AS LTV_28

FROM 
    retention_by_day rbd
LEFT JOIN 
    arpu_by_platform_country abpc
    ON rbd.platform = abpc.platform
    AND rbd.country = abpc.country
ORDER BY 
    rbd.platform;
