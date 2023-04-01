resource "aws_kinesisanalyticsv2_application" "kinesisflink" {
  name                   = "FlinkHudiApp"
  runtime_environment    = "FLINK-1_15"
  service_execution_role = aws_iam_role.flink_app_role.arn

  cloudwatch_logging_options {
      log_stream_arn = aws_cloudwatch_log_stream.flink_hudi_log_stream.arn
  }
  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = aws_s3_bucket.flink_hudi_bucket.arn
          file_key   = aws_s3_object.flink_hudi_s3_key.key
        }
      }
      code_content_type = "ZIPFILE"
    }

    environment_properties {
      property_group {
        property_group_id = "kinesis.analytics.flink.run.options"
        property_map = {
          "python" = "flink_app.py"
          "jarfile" = "lib/combined.jar"
        }
      }
      property_group {
        property_group_id = "consumer.config.0"
        property_map = {
          "aws.region" = var.aws_region
          "input.stream.name" =  aws_kinesis_stream.inbound_kinesis.name
          "scan.stream.initpos" = "LATEST"
        }
      }

      property_group {
        property_group_id = "sink.config.0"
        property_map = {
          "output.bucket.name" = var.bucket_name
          "output.format" = var.output_format
        }
      }
    }

    flink_application_configuration {
      parallelism_configuration {
        auto_scaling_enabled = true
        configuration_type   = "CUSTOM"
        parallelism = 1
        parallelism_per_kpu = 1
      }

      checkpoint_configuration {
        configuration_type   = "CUSTOM"
        checkpointing_enabled = true
        checkpoint_interval = 5000
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
