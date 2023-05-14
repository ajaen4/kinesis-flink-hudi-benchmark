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

variable "json_database_name" {
  description = "Athena json database"
  type        = string
}

variable "hudi_database_name" {
  description = "Athena hudi database"
  type        = string
}

variable "json_table_name" {
  description = "Athena json table"
  type        = string
}

variable "hudi_table_name" {
  description = "Athena hudi table"
  type        = string
}