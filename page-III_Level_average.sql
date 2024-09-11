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

levels_played_by_day AS (
    -- number of levels played by users on specific days after their install
    SELECT 
        i.user_id,
        i.platform,
        i.country,
        i.install_date,
        
        -- Count levels played on D0 (install day)
        COUNT(CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 0 DAY) AND e.event_name = 'level_start' THEN e.level_name END) AS levels_D0,
        
        -- Count levels played on D1
        COUNT(CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 1 DAY) AND e.event_name = 'level_start' THEN e.level_name END) AS levels_D1,
        
        -- Count levels played on D3
        COUNT(CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 3 DAY) AND e.event_name = 'level_start' THEN e.level_name END) AS levels_D3,
        
        -- Count levels played on D7
        COUNT(CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 7 DAY) AND e.event_name = 'level_start' THEN e.level_name END) AS levels_D7,
        
        -- Count levels played on D14
        COUNT(CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 14 DAY) AND e.event_name = 'level_start' THEN e.level_name END) AS levels_D14,
        
        -- Count levels played on D28
        COUNT(CASE WHEN e.event_date = DATE_ADD(i.install_date, INTERVAL 28 DAY) AND e.event_name = 'level_start' THEN e.level_name END) AS levels_D28
    FROM 
        installs i
    LEFT JOIN 
        `analytics_v2.clustered_events` e 
        ON i.user_id = e.user_id  
    GROUP BY 
        i.user_id, i.platform, i.country, i.install_date
),

cumulative_levels AS (
    -- Calculate cumulative levels
    SELECT 
        platform,
        country,

        -- Average cumulative levels for D0
        AVG(levels_D0) AS avg_levels_D0,

        -- Average cumulative levels for D1 = levels_D0 + levels_D1
        AVG(levels_D0 + levels_D1) AS avg_levels_D1,

        -- Average cumulative levels for D3 = levels_D0 + levels_D1 + levels_D3
        AVG(levels_D0 + levels_D1 + levels_D3) AS avg_levels_D3,

        -- Average cumulative levels for D7 = levels_D0 + levels_D1 + levels_D3 + levels_D7
        AVG(levels_D0 + levels_D1 + levels_D3 + levels_D7) AS avg_levels_D7,

        -- Average cumulative levels for D14 = levels_D0 + levels_D1 + levels_D3 + levels_D7 + levels_D14
        AVG(levels_D0 + levels_D1 + levels_D3 + levels_D7 + levels_D14) AS avg_levels_D14,

        -- Average cumulative levels for D28 = levels_D0 + levels_D1 + levels_D3 + levels_D7 + levels_D14 + levels_D28
        AVG(levels_D0 + levels_D1 + levels_D3 + levels_D7 + levels_D14 + levels_D28) AS avg_levels_D28
    FROM 
        levels_played_by_day
    GROUP BY 
        platform, country
)


SELECT 
    platform,
    country,
    avg_levels_D0,
    avg_levels_D1,
    avg_levels_D3,
    avg_levels_D7,
    avg_levels_D14,
    avg_levels_D28
FROM 
    cumulative_levels
ORDER BY 
    platform, country;
