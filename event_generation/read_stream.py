import json

import config as cfg
from services import kinesis_client


def get_shard_iterator(stream_name):
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

    shard_iterator = get_shard_iterator(stream_name)

    while True:
        record_response = kinesis_client.get_records(ShardIterator=shard_iterator)

        for record in record_response["Records"]:
            print(json.loads(record["Data"]))

        shard_iterator = record_response["NextShardIterator"]


if __name__ == "__main__":
    iterate_stream(cfg.STREAM_NAME)
