from datetime import datetime
import random
import json
import uuid

from locust import User, task, between, tag
import boto3

import config as cfg
from tickers import Tickers


def read_previous_event(file_path):
    with open(file_path, "r") as f:
        line = next(f)
        for num, aline in enumerate(f, 2):
            if random.randrange(num):
                continue
            line = aline
    return json.loads(line)


class StockUser(User):
    wait_time = between(1, 1)

    def on_start(self):
        self.kinesis_client = boto3.client("kinesis")
        self.stream_name = cfg.STREAM_NAME

    @tag("send")
    @task
    def send_stock_values(self):
        ticker = random.choice(list(Tickers))
        event_id = str(uuid.uuid4())
        data = StockUser.get_data(ticker.value, event_id)
        self.kinesis_client.put_record(
            StreamName=self.stream_name,
            Data=data,
            PartitionKey=event_id,
        )

        ticker = random.choice(list(Tickers))

    @tag("send-save")
    @task
    def send_and_save_stock_values(self):
        with open("events/events.json", "a") as events:
            ticker = random.choice(list(Tickers))
            event_id = str(uuid.uuid4())
            data = StockUser.get_data(ticker.value, event_id)
            self.kinesis_client.put_record(
                StreamName=self.stream_name,
                Data=data,
                PartitionKey=event_id,
            )
            events.write(data)
            events.write("\n")

    @tag("send-inserts")
    @task
    def send_stock_inserts(self):
        with open("events/inserts.json", "a") as inserts:
            prev_event = read_previous_event("events/events.json")
            event_id = prev_event["event_id"]
            ticker = prev_event["ticker"]
            data = StockUser.get_data(ticker, event_id)

            self.kinesis_client.put_record(
                StreamName=self.stream_name,
                Data=data,
                PartitionKey=event_id,
            )
            inserts.write(data)
            inserts.write("\n")

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
