variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "bucket_name" {
  description = "S3 Bucket name"
  type        = string
}

variable "inbound_kinesis" {
  description = "Kinesis Stream name for inbound data"
  type        = string
}
