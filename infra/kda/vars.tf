variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "artifacts_bucket" {
  description = "Bucket name for output data"
  type        = string
}

variable "code_s3_key" {
  description = "S3 key for Flink application packaged code"
  type        = string
}

variable "output_format" {
  description = "Output format stored in S3 (hudi | json | print)"
  type        = string
}

variable "hudi_table_type" {
  description = "Hudi table type (MoR | CoW)"
  type        = string
  default     = null 
}

variable "source_stream_name" {
  description = "Kinesis Stream name for source data"
  type        = string
}

variable "kda_config" {
  description = "Kinesis Data Analytics configuration"
  type = object(
    {
      runtime_environment = string
      python              = string
      jarfile             = string
      parallelism         = number
      parallelism_per_kpu = number
      stream_inipos       = string
      checkpoint_interval = number
      log_level           = string
      metrics_level       = string
    }
  )
  default = {
    runtime_environment = "FLINK-1_15"
    python              = "flink_app.py"
    jarfile             = "lib/combined.jar"
    parallelism         = 1
    parallelism_per_kpu = 1
    stream_inipos       = "LATEST"
    checkpoint_interval = 5000
    log_level           = "INFO"
    metrics_level       = "TASK"
  }
}
