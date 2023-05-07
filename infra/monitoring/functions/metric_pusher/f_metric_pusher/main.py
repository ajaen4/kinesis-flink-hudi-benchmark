from f_metric_pusher.service import cloudwatch_service, athena_service
from f_metric_pusher.queries import COUNT_QUERY
from f_metric_pusher.env_variables import (
    DATABASE_NAME,
    TABLE_NAME,
)


def main(event, context):
    print("Starting metric pusher lambda")

    query_result = athena_service.execute_query(
        COUNT_QUERY.format(database_name=DATABASE_NAME, table_name=TABLE_NAME)
    )
    count_value = int(query_result[1]["Data"][0]["VarCharValue"])

    cloudwatch_service.push_metric(
        metric={
            "metric_name": "hudi-json-benchmark",
            "table_name": TABLE_NAME,
            "value": count_value,
        }
    )
    print("Finished metric pusher lambda")
