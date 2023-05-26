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

variable "glue_database_name" {
  description = "Glue Catalog database name"
  type        = string
}

variable "json_table_name" {
  description = "Athena json table"
  type        = string
}

variable "hudi_mor_table_name" {
  description = "Athena hudi mor table"
  type        = string
}

variable "hudi_cow_table_name" {
  description = "Athena hudi cow table"
  type        = string
}
