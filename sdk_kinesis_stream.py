import json, uuid, boto3

from aws_credentials import get_aws_credentials

KINESIS_REGION_NAME = 'us-west-1'   # If you wanna keep this secret, hide it obviously. #justsaying

class KinesisStream(object):
    
    def __init__(self, stream):
        self.stream = stream
        """ Connect to Kinesis Streams """
        session = boto3.Session(profile_name="practica")
        self.kinesis =  session.client('kinesis',
                            region_name="eu-west-1")

    def send_stream(self, data, partition_key=None):
        """
        data: python dict containing your data.
        partition_key:  set it to some fixed value if you want processing order
                        to be preserved when writing successive records.
                        
                        If your kinesis stream has multiple shards, AWS hashes your
                        partition key to decide which shard to send this record to.
                        
                        Ignore if you don't care for processing order
                        or if this stream only has 1 shard.
                        
                        If your kinesis stream is small, it probably only has 1 shard anyway.
        """

        # If no partition key is given, assume random sharding for even shard write load
        if partition_key == None:
            partition_key = uuid.uuid4()
            partition_key = "9e638d74-62b0-4e95-918f-7eb3e51e5a86"


        return self.kinesis.put_record(
            StreamName=self.stream,
            Data=json.dumps(data),
            PartitionKey=partition_key
        )

    def read_kinesis(self, stream_name):
        kinesis_iterator = self._get_kinesis_data_iterator(stream_name)
        for records in kinesis_iterator:
            if len(records['Records']) > 0:
                print(records['Records'])
    
    def _get_kinesis_data_iterator(self, stream_name):
        kinesis_stream = self.kinesis.describe_stream(StreamName=stream_name)
        shards = kinesis_stream['StreamDescription']['Shards']
        shard_ids = [shard['ShardId'] for shard in shards]

        iter_response = self.kinesis.get_shard_iterator(
            StreamName=stream_name,
            ShardId=shard_ids[0],
            ShardIteratorType="TRIM_HORIZON"
        )
        shard_iterator = iter_response['ShardIterator']

        while True:
            record_response = self.kinesis.get_records(ShardIterator=shard_iterator)
            yield record_response
            shard_iterator = record_response['NextShardIterator']

    STREAM_NAME = 'kinesis-flink-hudi-stream'

