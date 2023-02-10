from sdk_kinesis_stream import KinesisStream
data = {'my': 'data'}
stream = KinesisStream('kinesis-flink-hudi-stream')
response = stream.read_kinesis("kinesis-flink-hudi-stream")
print(response)