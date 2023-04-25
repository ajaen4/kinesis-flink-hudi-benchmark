SOURCE_SCHEMA = """
    event_id varchar,
    ticker VARCHAR(6),
    price DOUBLE,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
"""

SINK_SCHEMA = """
    event_id varchar,
    ticker VARCHAR(6),
    price DOUBLE,
    event_time TIMESTAMP(3)
"""

HUDI_OPTIONS = """
    'table.type' = 'MERGE_ON_READ',
    'hoodie.datasource.write.recordkey.field' = 'event_id',
    'hoodie.embed.timeline.server' = 'false',
    'read.streaming.enabled' = 'true',
    'metadata.compaction.delta_commits'='1',
    'hive_sync.enable' = 'true',
    'hive_sync.db' = 'hudi',
    'hive_sync.table' = 'hudi-benchmark',
    'hive_sync.mode' = 'glue',
    'hive_sync.partition_fields' = 'ticker',
    'hive_sync.use_jdbc' = 'false'
"""


def create_kinesis_table(
    table_name: str,
    stream_name: str,
    region: str,
    stream_initpos: str,
) -> str:
    return """
        CREATE TABLE {table_name} (
            {table_schema}
        )
        PARTITIONED BY (ticker)
        WITH (
            'connector' = 'kinesis',
            'stream' = '{stream_name}',
            'aws.region' = '{region}',
            'scan.stream.initpos' = '{stream_initpos}',
            'format' = 'json',
            'json.timestamp-format.standard' = 'ISO-8601'
        )
    """.format(
        table_name=table_name,
        table_schema=SOURCE_SCHEMA,
        stream_name=stream_name,
        region=region,
        stream_initpos=stream_initpos,
    )


def create_json_table(table_name: str, bucket_name: str) -> str:
    return """
        CREATE TABLE {table_name} (
            {table_schema}
        )
        WITH (
            'connector'='filesystem',
            'path'='s3a://{bucket_name}/',
            'format'='json'
        )
    """.format(
        table_name=table_name,
        table_schema=SINK_SCHEMA,
        bucket_name=bucket_name,
    )


def create_hudi_table(table_name: str, bucket_name: str) -> str:
    return """
        CREATE TABLE {table_name} (
            {table_schema}
        )
        PARTITIONED BY (ticker)
        WITH (
            'connector' = 'hudi',
            'path'='s3a://{bucket_name}/',
            {hudi_options}
        )
    """.format(
        table_name=table_name,
        table_schema=SINK_SCHEMA,
        bucket_name=bucket_name,
        hudi_options=HUDI_OPTIONS,
    )


def create_print_table(table_name: str) -> str:
    return """
        CREATE TABLE {table_name} (
            {table_schema}
        )
        WITH (
            'connector'='print'
        )
    """.format(
        table_name=table_name,
        table_schema=SINK_SCHEMA,
    )


def create_sink_table(
    output_format: str,
    output_table_name: str,
    output_bucket_name: str = None,
) -> str:
    if output_format == "json":
        return create_json_table(output_table_name, output_bucket_name)

    if output_format == "hudi":
        return create_hudi_table(output_table_name, output_bucket_name)

    if output_format == "print":
        return create_print_table(output_table_name)
