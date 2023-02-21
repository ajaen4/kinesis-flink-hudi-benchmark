from pyflink.table import EnvironmentSettings, StreamTableEnvironment
import os
import json

# 1. Creates a Table Environment
env_settings = (
    EnvironmentSettings
    .new_instance()
    .in_streaming_mode()
    .build()
)
table_env = StreamTableEnvironment.create(environment_settings=env_settings)

APPLICATION_PROPERTIES_FILE_PATH = "/etc/flink/application_properties.json"  # on kda

#os.environ["IS_LOCAL"] = "true"

is_local = (
    True if os.environ.get("IS_LOCAL") else False
)  # set this env var in your local environment

if is_local:
    # only for local, overwrite variable to properties and pass in your jars delimited by a semicolon (;)
    APPLICATION_PROPERTIES_FILE_PATH = "flink-app/application_properties.json"  # local

    CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
    table_env.get_config().get_configuration().set_string(
        "pipeline.jars",
        "file:///"
        + CURRENT_DIR
        + "/lib/flink-sql-connector-kinesis-1.15.2.jar;file:///"
        + CURRENT_DIR
        + "/plugins/flink-s3-fs-hadoop/flink-s3-fs-hadoop-1.11.2.jar",
    )

    table_env.get_config().get_configuration().set_string(
        "execution.checkpointing.mode", "EXACTLY_ONCE"
    )
    table_env.get_config().get_configuration().set_string(
        "execution.checkpointing.interval", "1min"
    )


def get_application_properties():
    if os.path.isfile(APPLICATION_PROPERTIES_FILE_PATH):
        with open(APPLICATION_PROPERTIES_FILE_PATH, "r") as file:
            contents = file.read()
            properties = json.loads(contents)
            return properties
    else:
        print('A file at "{}" was not found'.format(APPLICATION_PROPERTIES_FILE_PATH))


def property_map(props, property_group_id):
    for prop in props:
        if prop["PropertyGroupId"] == property_group_id:
            return prop["PropertyMap"]


def create_source_table(table_name, stream_name, region, stream_initpos = None):
    init_pos = "\n'scan.stream.initpos' = '{0}',".format(stream_initpos) if stream_initpos is not None else ''

    query = """ CREATE TABLE {0} (
                ticker VARCHAR(6),
                price DOUBLE,
                event_time TIMESTAMP(3),
                WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
              )
              PARTITIONED BY (ticker)
              WITH (
                'connector' = 'kinesis',
                'stream' = '{1}',
                'aws.region' = '{2}',{3}
                'format' = 'json',
                'json.timestamp-format.standard' = 'ISO-8601'
              ) """.format(table_name, stream_name, region, init_pos)
    return query

def print_table(table_name):

    query = """ CREATE TABLE {0} (
                ticker VARCHAR(6),
                price DOUBLE,
                event_time TIMESTAMP(3),
                WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
              )
              PARTITIONED BY (ticker)
              WITH (
                'connector' = 'print'
              ) """.format(table_name)
    return query


def create_sink_table(table_name, bucket_name):
    return """ CREATE TABLE {0} (
                ticker VARCHAR(6),
                price DOUBLE,
                event_time TIMESTAMP(3),
                WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
              )
              WITH (
                  'connector'='filesystem',
                  'path'='s3a://{1}/flink_output/',
                  'format'='json',
                  'sink.partition-commit.policy.kind'='success-file',
                  'sink.partition-commit.delay' = '1 min'
              ) """.format(table_name, bucket_name)






def main():
    # Application Property Keys
    input_property_group_key = "consumer.config.0"
    sink_property_group_key = "sink.config.0"

    input_stream_key = "input.stream.name"
    input_region_key = "aws.input_property_mapregion"
    input_starting_position_key = "scan.stream.initpos"

    output_sink_key = "output.bucket.name"

    # tables
    input_table_name = "inputtable"
    output_table_name = "outputtable"

    # get application properties
    props = get_application_properties()
    
    input_property_map = property_map(props, input_property_group_key)
    output_property_map = property_map(props, sink_property_group_key)

    input_stream = input_property_map[input_stream_key]
    input_region = input_property_map[input_region_key]
    stream_initpos = input_property_map[input_starting_position_key]

    output_bucket_name = output_property_map[output_sink_key]

    # 1. print table test
    #table_env.execute_sql(print_table(output_table_name))

    # 2. Creates a source table from a Kinesis Data Stream
    table_env.execute_sql(create_source_table(input_table_name, input_stream, input_region, stream_initpos))

    # 3. Creates a sink table writing to an S3 Bucket
    table_env.execute_sql(create_sink_table(output_table_name, output_bucket_name))

    # 5. These tumbling windows are inserted into the sink table (S3)
    table_result = table_env.execute_sql("INSERT INTO {0} SELECT * FROM {1}"
                                          .format(output_table_name, input_table_name))
    
    

if __name__ == "__main__":
    main()
