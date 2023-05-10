import os
from pyflink.table import EnvironmentSettings, StreamTableEnvironment
from utils.config import set_local_environment, get_application_properties
from utils.tables import create_kinesis_table, create_sink_table


env_settings = EnvironmentSettings.in_streaming_mode()
table_env = StreamTableEnvironment.create(environment_settings=env_settings)
table_env.get_config().get_configuration().set_string("table.local-time-zone", "UTC")
is_local = True if os.environ.get("IS_LOCAL") else False

if is_local:
    set_local_environment(table_env)


def main() -> None:
    input_table_name = "input_table"
    output_table_name = "output_table"

    props = get_application_properties(is_local)

    input_stream = props["consumer.config.0"]["input.stream.name"]
    input_region = props["consumer.config.0"]["aws.region"]
    stream_initpos = props["consumer.config.0"]["scan.stream.initpos"]

    output_bucket_name = props["sink.config.0"]["output.bucket.name"]
    output_format = props["sink.config.0"]["output.format"]
    output_table_type = props["sink.config.0"].get("output.table.type", output_format)
    output_glue_database = props["sink.config.0"]["output.glue.database"]

    table_env.execute_sql(
        create_kinesis_table(
            input_table_name,
            input_stream,
            input_region,
            stream_initpos,
            output_table_type,
        )
    )
    table_env.execute_sql(
        create_sink_table(
            output_format,
            output_table_type,
            output_table_name,
            output_bucket_name,
            output_glue_database,
        )
    )
    table_result = table_env.execute_sql(
        """INSERT INTO {0}
            SELECT
                event_id,
                ticker,
                price,
                1000 * UNIX_TIMESTAMP(CAST(event_time AS STRING)) + EXTRACT(MILLISECOND FROM event_time),
                1000 * UNIX_TIMESTAMP(CAST(processing_time AS STRING)) + EXTRACT(MILLISECOND FROM processing_time)
            FROM {1}""".format(
            output_table_name, input_table_name
        )
    )

    if is_local:
        table_result.wait()


if __name__ == "__main__":
    main()
