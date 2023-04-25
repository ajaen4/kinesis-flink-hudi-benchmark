from datetime import datetime
import random
import json
import uuid

from locust import User, task, between
import boto3

import config as cfg
from tickers import Tickers


class StockUser(User):
    wait_time = between(1, 1)

    def on_start(self):
        self.kinesis_client = boto3.client("kinesis")
        self.stream_name = cfg.STREAM_NAME

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
                "event_time": datetime.utcnow().isoformat(),
                "ticker": ticker_value,
                "price": round(random.random() * 100, 2),
            }
        )
