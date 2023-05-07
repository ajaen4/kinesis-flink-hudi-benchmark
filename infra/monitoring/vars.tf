variable "aws_region_name" {
  description = "AWS Region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to push to ECR and use in lambda"
  type        = string
}

variable "database_name" {
  description = "Athena database where the table to query is"
  type        = string
}

variable "table_name" {
  description = "Table to query to obtain record count from lambda"
  type        = string
}
