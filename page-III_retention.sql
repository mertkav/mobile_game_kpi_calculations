WITH installs AS (
    -- users' install date (D0) to calculate retention for the US
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
        and 
        event_name in ( 'level_start', "GameStart", "InitialGameStart")
),

retention_by_day AS (
    -- Step 2: Calculate retention by day 
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
)

-- Step 3: Calculate the retention rate percentages for the US
SELECT 
    platform,
    country,
    D0_users,

    -- Retention rate for Day 1 
    CASE 
        WHEN D0_users > 0 THEN (D1_retained / D0_users) * 100
        ELSE 0 
    END AS R_1,  

    -- Retention rate for Day 3 
    CASE 
        WHEN D0_users > 0 THEN (D3_retained / D0_users) * 100
        ELSE 0 
    END AS R_3,

    -- Retention rate for Day 7 
    CASE 
        WHEN D0_users > 0 THEN (D7_retained / D0_users) * 100
        ELSE 0 
    END AS R_7,

    -- Retention rate for Day 14 
    CASE 
        WHEN D0_users > 0 THEN (D14_retained / D0_users) * 100
        ELSE 0 
    END AS R_14,

    -- Retention rate for Day 28
    CASE 
        WHEN D0_users > 0 THEN (D28_retained / D0_users) * 100
        ELSE 0 
    END AS R_28

FROM 
    retention_by_day
WHERE 
    country = 'us'  
ORDER BY 
    platform;
