resource "aws_s3_bucket" "hudipractica" {
  bucket = "flink-hudi-practica"

}

#resource "aws_s3_object" "hudipracticafiles" {
#  bucket = aws_s3_bucket.hudipractica.bucket
#  key    = "hudipracticafiles"
#}

resource "aws_s3_object" "hudipracticaflink" {
  bucket = aws_s3_bucket.hudipractica.bucket
  key    = "flink-app"
  source = "flink-app.jar"
}

resource "aws_iam_role" "practicahudiflinktest" {
  name = "practicahudiflinktest"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
          #type        = "Service"
          #identifiers = ["kinesis_analytics.amazonaws.com"]
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_kinesis_stream" "kinesisflink" {
  name             = "kinesis-flink-hudi-stream"
  #shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Environment = "test"
  }
}

resource "aws_kinesisanalyticsv2_application" "kinesisflink" {
  name                   = "kinesis-flink-hudi-application"
  runtime_environment    = "FLINK-1_8"
  service_execution_role = aws_iam_role.practicahudiflinktest.arn
  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = aws_s3_bucket.hudipractica.arn
          file_key   = aws_s3_object.hudipracticaflink.key
        }
      }

      code_content_type = "ZIPFILE"
    }

    environment_properties {
      property_group {
        property_group_id = "PROPERTY-GROUP-1"

        property_map = {
          "input.stream.name" = aws_kinesis_stream.kinesisflink.name
          "table.name": "input"
        }

      }
    }
  }
}

