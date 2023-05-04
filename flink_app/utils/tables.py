from .enums import HudiTableType

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
    event_time TIMESTAMP(3),
    processing_time TIMESTAMP_LTZ(3)
"""

HUDI_OPTIONS = """
    'table.type' = '{table_type}',
    'hoodie.datasource.write.recordkey.field' = 'event_id',
    'hoodie.embed.timeline.server' = 'false',
    'read.streaming.enabled' = 'true',
    'read.streaming.skip_compaction' = 'true',
    'changelog.enabled'='true',
    'compaction.delta_seconds'='60',
    'compaction.delta_commits'='1',
    'compaction.trigger.strategy'='num_or_time',
    'hoodie.cleaner.commits.retained' = '4',
    'hoodie.keep.min.commits' = '20',
    'hoodie.keep.max.commits' = '30',
    'hive_sync.enable' = 'true',
    'hive_sync.db' = 'hudi',
    'hive_sync.table' = 'ticker_hudi_{table_suffix}',
    'hive_sync.mode' = 'glue',
    'hive_sync.partition_fields' = 'ticker',
    'hive_sync.use_jdbc' = 'false'
"""


def get_hudi_options(hudi_table_type: str) -> str:
    return HUDI_OPTIONS.format(
        table_type=HudiTableType[hudi_table_type.lower()].value,
        table_suffix=hudi_table_type.lower(),
    )


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
            'json.timestamp-format.standard' = 'ISO-8601',
            'scan.shard.adaptivereads' = 'true'
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
        PARTITIONED BY (ticker)
        WITH (
            'connector'='filesystem',
            'path'='s3a://{bucket_name}/flink_output_json/',
            'format'='json'
        )
    """.format(
        table_name=table_name,
        table_schema=SINK_SCHEMA,
        bucket_name=bucket_name,
    )


def create_hudi_table(
    hudi_table_type: str,
    table_name: str,
    bucket_name: str,
) -> str:
    return """
        CREATE TABLE {table_name} (
            {table_schema}
        )
        PARTITIONED BY (ticker)
        WITH (
            'connector' = 'hudi',
            'path'='s3a://{bucket_name}/table_{table_suffix}/',
            {hudi_options}
        )
    """.format(
        table_name=table_name,
        table_schema=SINK_SCHEMA,
        bucket_name=bucket_name,
        hudi_options=get_hudi_options(hudi_table_type),
        table_suffix=hudi_table_type.lower(),
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
    hudi_table_type: str,
    output_table_name: str,
    output_bucket_name: str = None,
) -> str:
    if output_format == "json":
        return create_json_table(output_table_name, output_bucket_name)

    if output_format == "hudi":
        return create_hudi_table(hudi_table_type, output_table_name, output_bucket_name)

    if output_format == "print":
        return create_print_table(output_table_name)
