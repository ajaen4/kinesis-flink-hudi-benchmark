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
  name = "hudi-flink-role"

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

  inline_policy {
    name = "s3-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["s3:*"]
            Effect   = "Allow"
            Resource = [
              "arn:aws:s3:::flink-hudi-practica/",
              "arn:aws:s3:::flink-hudi-practica/*",
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
              "arn:aws:kinesis:eu-west-1:482861842012:stream/kinesis-flink-hudi-stream"
            ]
          },
          {
            Action   = ["kinesis:ListShards"]
            Effect   = "Allow"
            Resource = [
              "arn:aws:kinesis:eu-west-1:482861842012:stream/*"
            ]
          },
        ]
      })
  }

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
  runtime_environment    = "FLINK-1_15"
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
        property_group_id = "ProducerConfigProperties"
        property_map = {
          "aws.region" = "eu-west-1"
          "AggregationEnabled" =  "false"
          "flink.inputstream.initpos" = "LATEST"
        }

      }
    }
  }
}

