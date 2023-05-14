LATENCY_JSON_QUERY = """
    SELECT 
            ROUND(avg((TO_UNIXTIME(parse_datetime(replace(processing_time, 'Z', ''), 'yyyy-MM-dd HH:mm:ss.SSS')) - TO_UNIXTIME(parse_datetime(event_time, 'yyyy-MM-dd HH:mm:ss.SSSSSS')))*1000), 0) as processing_avg_ms
    FROM {database_name}."{table_name}";
"""
