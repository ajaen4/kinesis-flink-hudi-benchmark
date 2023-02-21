
import random
import string
from datetime import datetime
from time import sleep
from kinesis import KinesisStream


stream = KinesisStream('kinesis-flink-hudi-stream')


def kinesis_record_generator(rate=1):
    while True:
        record = {
            "ticker": get_random_string(5),
            "price": random.uniform(1, 100),
            "event_time": datetime.now().isoformat(),
        }
        yield record
        sleep(rate)


def get_random_string(length):
    letters = string.ascii_lowercase
    result_str = ''.join(random.choice(letters) for i in range(length))
    return result_str


if __name__ == "__main__":
    for record in kinesis_record_generator(rate=5):
        print(record)
        response = stream.send_record(record)
        print(response)