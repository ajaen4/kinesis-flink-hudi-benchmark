from f_metric_pusher.service import cloudwatch_service, athena_service
from f_metric_pusher.queries import COUNT_QUERY, LATENCY_HUDI_QUERY, LATENCY_JSON_QUERY
from f_metric_pusher.env_variables import database_name, table_name, output_format
from datetime import datetime


def count_query_push_metric(metric_name, database_name, table_name):

    count_query_result = athena_service.execute_query(
        COUNT_QUERY.format(
            database_name=database_name,
            table_name=table_name,
        )
    )[1]["Data"][0]["VarCharValue"]
    
    cloudwatch_service.push_metric(
        metric={
            "metric_name": metric_name,
            "table_name": table_name,
            "value": int(count_query_result),
            "timestamp": datetime.now(),
        },
    )

def latency_query_push_metric(metric_name, database_name, table_name):

    if output_format == "hudi":
        latency_query_imported = LATENCY_HUDI_QUERY
    else:
        latency_query_imported = LATENCY_JSON_QUERY
    
    
    latency_query_result = athena_service.execute_query(
        latency_query_imported.format(
            database_name=database_name,
            table_name=table_name,
        )
    )[1]["Data"][0]["VarCharValue"]

    cloudwatch_service.push_metric(
        metric={
            "metric_name": metric_name,
            "table_name": table_name,
            "value": float(latency_query_result),
            "timestamp": datetime.now(),
        },
    )

def main(event, context):
    print("Starting", output_format, "pusher lambda")

    count_query_push_metric(output_format + "_count", database_name, table_name)

    print("Finished", output_format + "_count pusher lambda")

    latency_query_push_metric(output_format + "_latency", database_name, table_name)

    print("Finished", output_format + "_latency pusher lambda")
