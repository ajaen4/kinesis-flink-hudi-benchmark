variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name for artifacts"
  type        = string
}

variable "source_stream_name" {
  description = "Kinesis Stream name for inbound data"
  type        = string
}
