import json, uuid, boto3

from aws_credentials import get_aws_credentials

KINESIS_REGION_NAME = 'us-west-1'   # If you wanna keep this secret, hide it obviously. #justsaying

class KinesisStream(object):
    
    def __init__(self, stream):
        self.stream = stream

    def _connected_client(self):
        """ Connect to Kinesis Streams """
        access_key, secret_key, session_token = get_aws_credentials()
        return boto3.client('kinesis',
                            region_name="eu-west-1",
                            aws_access_key_id=access_key,
                            aws_secret_access_key=secret_key,
                            aws_session_token=session_token)

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

        client = self._connected_client()
        return client.put_record(
            StreamName=self.stream,
            Data=json.dumps(data),
            PartitionKey=partition_key
        )

