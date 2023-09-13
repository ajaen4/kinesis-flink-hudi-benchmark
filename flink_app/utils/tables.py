from .enums import HudiTableType
from . import config as cfg


SOURCE_SCHEMA = """
    event_id varchar,
    ticker VARCHAR(6),
    price DOUBLE,
    event_time TIMESTAMP(3),
    processing_time as PROCTIME(),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
"""

SINK_SCHEMA = """
    event_id varchar,
    ticker VARCHAR(6),
    price DOUBLE,
    event_time BIGINT,
    processing_time BIGINT
"""

HUDI_COW_OPTIONS = """
    'table.type' = '{table_type}',
    'hoodie.datasource.write.recordkey.field' = 'event_id',
    'hoodie.embed.timeline.server' = 'false',
    'clean.async.enabled' = 'true',
    'hoodie.clean.async' = 'true',
    'hive_sync.enable' = 'true',
    'hive_sync.db' = '{glue_database}',
    'hive_sync.table' = 'ticker_hudi_{table_suffix}',
    'hive_sync.mode' = 'glue',
    'hive_sync.partition_fields' = 'ticker',
    'hive_sync.use_jdbc' = 'false'
"""

HUDI_MOR_OPTIONS = """
    'table.type' = '{table_type}',
    'hoodie.datasource.write.recordkey.field' = 'event_id',
    'hoodie.embed.timeline.server' = 'false',
    'hoodie.compact.inline'='true',
    'hoodie.compact.inline.max.delta.seconds'='60',
    'hoodie.compact.inline.max.delta.commits'='1',
    'compaction.trigger.strategy'='num_or_time',
    'clean.async.enabled' = 'true',
    'hoodie.clean.async' = 'true',
    'hive_sync.enable' = 'true',
    'hive_sync.db' = '{glue_database}',
    'hive_sync.table' = 'ticker_hudi_{table_suffix}',
    'hive_sync.mode' = 'glue',
    'hive_sync.partition_fields' = 'ticker',
    'hive_sync.use_jdbc' = 'false'
"""

def get_hudi_options() -> str:
    table_suffix = cfg.output_table_type.lower()

    if table_suffix == "mor":
        HUDI_OPTIONS = HUDI_MOR_OPTIONS
    if table_suffix == "cow":
        HUDI_OPTIONS = HUDI_COW_OPTIONS

    return HUDI_OPTIONS.format(
        table_type=HudiTableType[table_suffix].value,
        table_suffix=table_suffix,
        glue_database=cfg.output_glue_database,
    )


def create_kinesis_table() -> str:
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
            'scan.shard.adaptivereads' = 'true',
            'scan.stream.recordpublisher' = 'EFO',
            'scan.stream.efo.registration' = 'EAGER',
            'scan.stream.efo.consumername' = '{table_type}'
        )
    """.format(
        table_name=cfg.input_table_name,
        table_schema=SOURCE_SCHEMA,
        stream_name=cfg.input_stream,
        region=cfg.input_region,
        stream_initpos=cfg.stream_initpos,
        table_type=cfg.output_table_type,
    )


def create_json_table() -> str:
    return """
        CREATE TABLE {table_name} (
            {table_schema}
        )
        PARTITIONED BY (ticker)
        WITH (
            'connector'='filesystem',
            'path'='s3a://{bucket_name}/table_json/',
            'format'='json',
            'sink.rolling-policy.rollover-interval' = '1s',
            'sink.rolling-policy.check-interval' = '1s'
        )
    """.format(
        table_name=cfg.output_table_name,
        table_schema=SINK_SCHEMA,
        bucket_name=cfg.output_bucket_name,
    )


def create_hudi_table() -> str:
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
        table_name=cfg.output_table_name,
        table_schema=SINK_SCHEMA,
        bucket_name=cfg.output_bucket_name,
        hudi_options=get_hudi_options(),
        table_suffix=cfg.output_table_type.lower(),
    )


def create_print_table() -> str:
    return """
        CREATE TABLE {table_name} (
            {table_schema}
        )
        WITH (
            'connector'='print'
        )
    """.format(
        table_name=cfg.output_table_name,
        table_schema=SINK_SCHEMA,
    )


def create_sink_table() -> str:
    if cfg.output_format == "json":
        return create_json_table()

    if cfg.output_format == "hudi":
        return create_hudi_table()

    if cfg.output_format == "print":
        return create_print_table()
