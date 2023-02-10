variable "aws_region" {
	type      = string
	default   = "eu-west-1"
}

variable "bucket_name" {
  description = "S3 Bucket name"
  type        = string
  default     = "flink-hudi-practica"
}

variable "inbound_kinesis" {
  description = "Kinesis Stream name for inbound data"
  type        = string
  default     = "kinesis-hudi-inbound"
}

variable "output_format" {
  description = "Output format stored in S3 (hudi | json | print)"
  type        = string
  default     = "hudi"
}
