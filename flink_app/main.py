import os
from utils.tables import create_kinesis_table, create_sink_table
from utils.environment import IS_LOCAL, ENV_TABLE
from utils.config import output_table_name, input_table_name


def main() -> None:
    ENV_TABLE.execute_sql(create_kinesis_table())
    ENV_TABLE.execute_sql(create_sink_table())
    table_result = ENV_TABLE.execute_sql(
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

    if IS_LOCAL:
        table_result.wait()


if __name__ == "__main__":
    main()
