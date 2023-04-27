from datetime import datetime
import random
import json
import uuid

from locust import User, task, between
import boto3

from enum import Enum

class Tickers(Enum):
    APPLE = "AAPL"
    AMAZON = "AMZN"
    MICROSOFT = "MSFT"


class StockUser(User):
    wait_time = between(1, 1)

    def on_start(self):
        self.kinesis_client = boto3.client("kinesis")
        self.stream_name = "kinesis-hudi-inbound"

    @task
    def send_stock_values(self):
        for ticker in Tickers:
            event_id = str(uuid.uuid4())
            data = StockUser.get_data(ticker.value, event_id)
            self.kinesis_client.put_record(
                StreamName=self.stream_name,
                Data=data,
                PartitionKey=event_id,
            )

    @staticmethod
    def get_data(ticker_value, event_id):
        return json.dumps(
            {
                "event_id": event_id,
                "event_time": datetime.now().isoformat(),
                "ticker": ticker_value,
                "price": round(random.random() * 100, 2),
            }
        )
    
def get_shard_iterator(kinesis_client, stream_name):
    kinesis_stream = kinesis_client.describe_stream(StreamName=stream_name)
    shards = kinesis_stream["StreamDescription"]["Shards"]

    # Take just first shard for sampling
    shard_id = shards[0]["ShardId"]

    iter_response = kinesis_client.get_shard_iterator(
        StreamName=stream_name,
        ShardId=shard_id,
        ShardIteratorType="TRIM_HORIZON",
    )
    return iter_response["ShardIterator"]


def iterate_stream(stream_name):
    kinesis_client = boto3.client("kinesis")

    shard_iterator = get_shard_iterator(kinesis_client, stream_name)

    while True:
        record_response = kinesis_client.get_records(ShardIterator=shard_iterator)

        for record in record_response["Records"]:
            print(json.loads(record["Data"]))

        shard_iterator = record_response["NextShardIterator"]


if __name__ == "__main__":
    iterate_stream("kinesis-hudi-inbound")


# from locust import HttpUser, task, between

# default_headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36'}

# class WebsiteUser(HttpUser):
#     wait_time = between(1, 5)

#     @task(1)
#     def get_index(self):
#         self.client.get("/", headers=default_headers)