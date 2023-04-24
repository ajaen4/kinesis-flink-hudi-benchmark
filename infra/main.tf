resource "aws_kinesis_stream" "inbound_kinesis" {
  name             = var.inbound_kinesis
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

module "kda_json" {
  source = "./kda"
  depends_on = [
    aws_s3_bucket.flink_hudi_bucket,
    aws_s3_object.flink_hudi_s3_key,
  ]

  code_s3_key      = aws_s3_object.flink_hudi_s3_key.key
  output_format    = "json"
  source_kinesis   = aws_kinesis_stream.inbound_kinesis.name
  artifacts_bucket = aws_s3_bucket.flink_hudi_bucket.bucket
}

module "kda_hudi" {
  source = "./kda"
  depends_on = [
    aws_s3_bucket.flink_hudi_bucket,
    aws_s3_object.flink_hudi_s3_key,
  ]

  code_s3_key      = aws_s3_object.flink_hudi_s3_key.key
  output_format    = "hudi"
  source_kinesis   = aws_kinesis_stream.inbound_kinesis.name
  artifacts_bucket = aws_s3_bucket.flink_hudi_bucket.bucket
}
