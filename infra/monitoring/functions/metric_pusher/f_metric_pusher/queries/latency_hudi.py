LATENCY_HUDI_QUERY = """
    SELECT 
            ROUND(avg(processing_time-event_time), 0) as processing_avg_ms
    FROM {database_name}."{table_name}";
"""
