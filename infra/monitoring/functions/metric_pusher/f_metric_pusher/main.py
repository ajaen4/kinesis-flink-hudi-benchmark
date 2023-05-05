
from f_metric_pusher.service import cloudwatch_service, athena_service
from f_metric_pusher.queries import COUNT_QUERY, LATENCY_QUERY
from f_metric_pusher.env_variables import (db_table_names, output_format)

def count_query_push_metric(metric_name, db_table_names):
    count_query_result = athena_service.execute_query(COUNT_QUERY.format(database_name=db_table_names[output_format][0], table_name=db_table_names[output_format][1]))

    cloudwatch_service.push_metric(
        metric={
            "metric_name": metric_name,
            "table_name": db_table_names[output_format][1],
            "value": count_query_result
        }
    )

def latency_query_push_metric(metric_name, db_table_names):
    count_query_result = athena_service.execute_query(LATENCY_QUERY.format(database_name=db_table_names[output_format][0], table_name=db_table_names[output_format][1]))

    cloudwatch_service.push_metric(
        metric={
            "metric_name": metric_name,
            "table_name": db_table_names[output_format][1],
            "value": count_query_result
        }
    )



def main(event, context):
    print("Starting",output_format,"pusher lambda")

    count_query_push_metric(output_format+"_count",db_table_names)

    latency_query_push_metric(output_format+"_count",db_table_names)

    print("Finished",output_format,"pusher lambda")
