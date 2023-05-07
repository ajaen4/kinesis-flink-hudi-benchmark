from datetime import datetime


class CloudwatchService:
    def __init__(self, function_name, session) -> None:
        self.function_name = function_name
        self.session = session
        self._client = self.session.client("cloudwatch")

    def push_metric(self, metric):

        timestamp = datetime.now()
        params = {
            "MetricData": [
                {
                    "MetricName": metric["metric_name"],
                    "Dimensions": [
                        {"Name": "table_name", "Value": metric["table_name"]},
                    ],
                    "StorageResolution": 1,
                    "Timestamp": timestamp,
                    "Unit": "Count",
                    "Value": metric["value"],
                }
            ],
            "Namespace": "kinesis-flink-hudi-benchmark",
        }

        print(f"Sending new Cloudwatch metric with params: {params}")
        response = self._client.put_metric_data(**params)
        print(f"(Response) Sent new Cloudwatch metric with response: {response}")
