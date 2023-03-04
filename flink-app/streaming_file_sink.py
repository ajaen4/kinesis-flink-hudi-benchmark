from pyflink.table import EnvironmentSettings, StreamTableEnvironment
import os
import json


env_settings = (
    EnvironmentSettings
    .new_instance()
    .in_streaming_mode()
    .build()
)

table_env = StreamTableEnvironment.create(environment_settings=env_settings)
#table_env.get_config().set("execution.checkpointing.mode", "EXACTLY_ONCE")
#table_env.get_config().set("execution.checkpointing.interval", "5000")
is_local = True


def set_local_jar():
    if is_local:
        print('We set the classpath here')
        CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
        table_env.get_config().get_configuration().set_string(
            'pipeline.jars',
            "file:///"
            + CURRENT_DIR
            + "/lib/combined-1.jar"
        )
    else:
        pass

set_local_jar()

def get_application_properties():
    if is_local:
        properties_filepath = "flink-app/application_properties.json"
    else:
        properties_filepath = "/etc/flink/application_properties.json"

    if os.path.isfile(properties_filepath):
        with open(properties_filepath, "r") as file:
            contents = file.read()
            properties = json.loads(contents)

        parsed_props = dict()
        for prop in properties:
            parsed_props[prop['PropertyGroupId']] = prop['PropertyMap']
        return parsed_props
    else:
        print('A file at "{}" was not found'.format(properties_filepath))

def create_table(table_name, stream_name, region, stream_initpos = None):
    init_pos = "\n'scan.stream.initpos' = '{0}',".format(stream_initpos) if stream_initpos is not None else ''

    query = """ CREATE TABLE {0} (
                ticker VARCHAR(6),
                price DOUBLE,
                event_time TIMESTAMP(3)
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


def create_print_table(table_name, bucket_name):
    print("Initializing printing in the console...")
    print(table_name)
    print(bucket_name)
    query = """ CREATE TABLE {0} (
                ticker VARCHAR(6),
                price DOUBLE,
                event_time TIMESTAMP(3)
              )
              PARTITIONED BY (ticker)
              WITH (
                'connector' = 'print'
              ) """.format(table_name)
    return query

def create_s3_table(table_name, bucket_name):
    query = """ CREATE TABLE {0} (
                ticker VARCHAR(6),
                price DOUBLE,
                event_time TIMESTAMP(3)
              )
              PARTITIONED BY (ticker)
              WITH (
                  'connector'='filesystem',
                  'path'='s3a://{1}/flink_output_json/',
                  'format'='json',
                  'sink.partition-commit.policy.kind'='success-file',
                  'sink.partition-commit.delay' = '1 min'
              ) """.format(table_name, bucket_name)
    return query

def create_hudi_table(table_name, bucket_name):
    print("Initializing hudi S3 writing...")
    print(table_name)
    print(bucket_name)
    return """ CREATE TABLE {0} (
                ticker VARCHAR(6),
                price DOUBLE,
                event_time TIMESTAMP(3)
              )
              PARTITIONED BY (ticker)
              WITH (
                  'connector' = 'hudi',
                  'path'='s3a://{1}/flink_output_hudi_6/',
                  'table.type' = 'MERGE_ON_READ',
                  'write.bucket_assign.tasks' = '4',
                  'read.streaming.enabled' = 'true',
                  'read.streaming.check-interval' = '4',
                  'write.tasks' = '4'
              ) """.format(table_name, bucket_name)

def main():
    props = get_application_properties()

    consumer_config_0 = props["consumer.config.0"]
    sink_config_0 = props["sink.config.0"]
    
    input_table_name = "ExampleInputStream"
    output_table_name = "ExampleOutputStream"

    input_stream = consumer_config_0["input.stream.name"]
    print("input stream:",input_stream)
    input_region = consumer_config_0["aws.region"]
    print("input region:",input_region)
    stream_initpos = consumer_config_0["scan.stream.initpos"]
    print("init pos:",stream_initpos)

    output_bucket_name = sink_config_0["output.bucket.name"]
    print("output bucket:",output_bucket_name)

    table_env.execute_sql(create_table(input_table_name, input_stream, input_region, stream_initpos))

    #table_env.execute_sql(create_print_table(output_table_name, output_bucket_name))
    #table_env.execute_sql(create_s3_table(output_table_name, output_bucket_name))
    table_env.execute_sql(create_hudi_table(output_table_name, output_bucket_name))

    table_result = table_env.execute_sql(
        "INSERT INTO {0} SELECT * FROM {1}".format(output_table_name, input_table_name)
    )

    if is_local:
        table_result.wait()
    

if __name__ == "__main__":
    main()