resource "aws_s3_bucket" "flink_hudi_bucket" {
  bucket = var.BUCKET_NAME

}

resource "null_resource" "local_exec_mvn_package" {
  provisioner "local-exec" {
    command = "cd fat_jar && mvn package"
  }
}

data "archive_file" "flink_zip" {
    type        = "zip"
    source_dir  = "../flink_app"
    output_path = "../flink_app.zip"
    depends_on = [null_resource.local_exec_mvn_package]
}

resource "aws_s3_object" "flink_hudi_s3_key" {
  bucket = aws_s3_bucket.flink_hudi_bucket.bucket
  key    = "${sha256(data.archive_file.flink_zip.output_base64sha256)}.zip"
  source = data.archive_file.flink_zip.output_path
}

resource "aws_iam_role" "flink_app_role" {
  name = "flink-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "s3-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["s3:*"]
            Effect   = "Allow"
            Resource = [
              "*",
            ]
          },
        ]
      })
  }

  inline_policy {
    name = "kinesis-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["kinesis:*"]
            Effect   = "Allow"
            Resource = [
              "arn:aws:kinesis:eu-west-1:482861842012:stream/${aws_kinesis_stream.inbound_kinesis.name}"
            ]
          },
          {
            Action   = ["kinesis:ListShards"]
            Effect   = "Allow"
            Resource = [
              "arn:aws:kinesis:eu-west-1:482861842012:stream/*"
            ]
          },
          {
            Action   = ["glue:*"]
            Effect   = "Allow"
            Resource = [
              "*"
            ]
          },
          {
            Action   = [
              "logs:*",
              "cloudwatch:*"
            ]
            Effect   = "Allow"
            Resource = [
              "*"
            ]
          },
        ]
      })
  }
}

resource "aws_kinesis_stream" "inbound_kinesis" {
  name             = var.INBOUND_KINESIS
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

resource "aws_cloudwatch_log_group" "flink_hudi_log_group" {
  name = "flink-hudi"
}

resource "aws_cloudwatch_log_stream" "flink_hudi_log_stream" {
  name           = "flink-hudi"
  log_group_name = aws_cloudwatch_log_group.flink_hudi_log_group.name
}

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
          "aws.region" = "${var.AWS_REGION}"
          "input.stream.name" =  "${aws_kinesis_stream.inbound_kinesis.name}"
          "scan.stream.initpos" = "LATEST"
        }
      }

      property_group {
        property_group_id = "sink.config.0"
        property_map = {
          "output.bucket.name" = "${var.BUCKET_NAME}"
          "output.format" = "${var.OUTPUT_FORMAT}"
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
