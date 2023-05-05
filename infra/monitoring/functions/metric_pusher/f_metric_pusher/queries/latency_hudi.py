LATENCY_QUERY = """
    SELECT 
            ROUND(avg(processing_time-event_time), 0) as processing_avg_ms
            , avg(TO_UNIXTIME(from_iso8601_timestamp(substring(_hoodie_commit_time, 1, 4) || '-' || 
                                substring(_hoodie_commit_time, 5, 2) || '-' || 
                                substring(_hoodie_commit_time, 7, 2) || 'T' || 
                                substring(_hoodie_commit_time, 9, 2) || ':' || 
                                substring(_hoodie_commit_time, 11, 2) || ':' || 
                                substring(_hoodie_commit_time, 13, 2) || '.' || 
                                substring(_hoodie_commit_time, 15, 3)))*1000 
            - processing_time) AS commiting_avg_ms
            , avg(TO_UNIXTIME(from_iso8601_timestamp(substring(_hoodie_commit_time, 1, 4) || '-' || 
                                substring(_hoodie_commit_time, 5, 2) || '-' || 
                                substring(_hoodie_commit_time, 7, 2) || 'T' || 
                                substring(_hoodie_commit_time, 9, 2) || ':' || 
                                substring(_hoodie_commit_time, 11, 2) || ':' || 
                                substring(_hoodie_commit_time, 13, 2) || '.' || 
                                substring(_hoodie_commit_time, 15, 3)))*1000 
            - event_time) AS full_time_ms
    FROM {database_name}."{table_name}";
"""