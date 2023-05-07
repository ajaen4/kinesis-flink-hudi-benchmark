data "aws_caller_identity" "current" {}

resource "aws_kinesis_stream" "inbound_kinesis" {
  name             = var.source_stream_name
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

module "kda_hudi_mor" {
  source = "./kda"

  depends_on = [
    aws_s3_bucket.flink_artifacts_bucket,
    aws_s3_object.flink_artifacts_s3_key,
  ]

  code_s3_key        = aws_s3_object.flink_artifacts_s3_key.key
  output_format      = "hudi"
  hudi_table_type    = "mor"
  source_stream_name = aws_kinesis_stream.inbound_kinesis.name
  artifacts_bucket   = aws_s3_bucket.flink_artifacts_bucket.bucket
}

module "kda_hudi_cow" {
  source = "./kda"

  depends_on = [
    aws_s3_bucket.flink_artifacts_bucket,
    aws_s3_object.flink_artifacts_s3_key,
  ]

  code_s3_key        = aws_s3_object.flink_artifacts_s3_key.key
  output_format      = "hudi"
  hudi_table_type    = "cow"
  source_stream_name = aws_kinesis_stream.inbound_kinesis.name
  artifacts_bucket   = aws_s3_bucket.flink_artifacts_bucket.bucket
}

module "kda_json" {
  source = "./kda"

  depends_on = [
    aws_s3_bucket.flink_artifacts_bucket,
    aws_s3_object.flink_artifacts_s3_key,
  ]

  code_s3_key        = aws_s3_object.flink_artifacts_s3_key.key
  output_format      = "json"
  source_stream_name = aws_kinesis_stream.inbound_kinesis.name
  artifacts_bucket   = aws_s3_bucket.flink_artifacts_bucket.bucket
}
