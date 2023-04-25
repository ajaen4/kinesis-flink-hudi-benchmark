import boto3
from f_metric_pusher.services import CloudwatchService, AthenaService

aws_session = boto3.Session()

cloudwatch_service = CloudwatchService(
    function_name="metric_pusher", session=aws_session
)
athena_service = AthenaService(
    session=aws_session,
    output_path="s3://482861842012-eu-west-1-athena-results-bucket-imiexwwws0/hudi-test/",
)
