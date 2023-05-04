locals {
  prefix = "flink-app"
  suffix = "practica"
  full_name = "${var.output_format == "hudi"
    ? "${local.prefix}-${local.suffix}-${var.hudi_table_type}"
    : "${local.prefix}-${local.suffix}-json"}"
}

data "aws_s3_bucket" "artifacts_bucket" {
  bucket = var.artifacts_bucket
}

data "aws_s3_object" "code_location" {
  bucket = data.aws_s3_bucket.artifacts_bucket.bucket
  key    = var.code_s3_key
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "${local.full_name}"
}

resource "aws_kinesisanalyticsv2_application" "kinesisflink" {
  name                   = "${local.full_name}"
  runtime_environment    = var.kda_config.runtime_environment
  service_execution_role = aws_iam_role.flink_app_role.arn

  cloudwatch_logging_options {
      log_stream_arn = aws_cloudwatch_log_stream.flink_hudi_log_stream.arn
  }
  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = data.aws_s3_bucket.artifacts_bucket.arn
          file_key   = data.aws_s3_object.code_location.key
        }
      }
      code_content_type = "ZIPFILE"
    }

    environment_properties {
      property_group {
        property_group_id = "kinesis.analytics.flink.run.options"
        property_map = {
          "python" = var.kda_config.python
          "jarfile" = var.kda_config.jarfile
        }
      }
      property_group {
        property_group_id = "consumer.config.0"
        property_map = {
          "aws.region" = var.aws_region
          "input.stream.name" =  var.source_stream_name
          "scan.stream.initpos" = var.kda_config.stream_inipos
        }
      }

      property_group {
        property_group_id = "sink.config.0"
        property_map = {
          "output.bucket.name" = aws_s3_bucket.output_bucket.bucket
          "output.format" = var.output_format
          "hudi.table.type" = var.hudi_table_type
        }
      }
    }

    flink_application_configuration {
      parallelism_configuration {
        auto_scaling_enabled = true
        configuration_type   = "CUSTOM"
        parallelism = var.kda_config.parallelism
        parallelism_per_kpu = var.kda_config.parallelism_per_kpu
      }

      checkpoint_configuration {
        configuration_type   = "CUSTOM"
        checkpointing_enabled = true
        checkpoint_interval = var.kda_config.checkpoint_interval
      }

      monitoring_configuration {
        configuration_type = "CUSTOM"
        log_level          = "INFO"
        metrics_level      = "TASK"
      }
    }

    run_configuration {
      flink_run_configuration {
        allow_non_restored_state = true
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "flink_hudi_log_group" {
  name = "${local.full_name}"
}

resource "aws_cloudwatch_log_stream" "flink_hudi_log_stream" {
  name           = "${local.full_name}"
  log_group_name = aws_cloudwatch_log_group.flink_hudi_log_group.name
}
