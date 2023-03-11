variable "AWS_REGION" {
	type      = string
	default   = "eu-west-1"
}

variable "BUCKET_NAME" {
  description = "S3 Bucket name"
  type        = string
  default     = "flink-hudi-practica"
}

variable "INBOUND_KINESIS" {
  description = "Kinesis Stream name for inbound data"
  type        = string
  default     = "kinesis-hudi-inbound"
}

variable "OUTPUT_FORMAT" {
  description = "Output format stored in S3 (hudi | json | print)"
  type        = string
  default     = "hudi"
}
