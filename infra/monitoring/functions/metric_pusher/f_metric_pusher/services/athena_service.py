import time


class AthenaService:
    def __init__(self, session, output_path) -> None:
        self.session = session
        self._client = session.client("athena")
        self.output_path = output_path

    def execute_query(self, query):
        result = self._client.start_query_execution(
            QueryString=query, ResultConfiguration={"OutputLocation": self.output_path}
        )

        self._wait_for_query_to_finish(result["QueryExecutionId"])
        return self._get_query_results(result["QueryExecutionId"])

    def _wait_for_query_to_finish(self, execution_id):
        state = "RUNNING"

        while state in ["RUNNING", "QUEUED"]:
            response = self._client.get_query_execution(QueryExecutionId=execution_id)
            if (
                "QueryExecution" in response
                and "Status" in response["QueryExecution"]
                and "State" in response["QueryExecution"]["Status"]
            ):
                state = response["QueryExecution"]["Status"]["State"]
                if state == "SUCCEEDED":
                    return True

            time.sleep(2)

    def _get_query_results(self, query_execution_id):
        return self._client.get_query_results(QueryExecutionId=query_execution_id,)[
            "ResultSet"
        ]["Rows"]
