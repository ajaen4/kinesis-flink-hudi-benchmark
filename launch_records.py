from sdk_kinesis_stream import KinesisStream
data = {'my': 'data'}
stream = KinesisStream('kinesis-flink-hudi-stream')
stream.send_stream(data=data)