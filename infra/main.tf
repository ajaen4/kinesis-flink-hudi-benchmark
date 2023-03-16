resource "aws_s3_bucket" "flink_hudi_bucket" {
  bucket = var.bucket_name

}

resource "null_resource" "local_exec_mvn_package" {
  provisioner "local-exec" {
    command = "cd .. && make uber-jar"
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
            Action   = "s3:*"
            Effect   = "Allow"
            Resource = "*"
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
              "arn:aws:kinesis:*:*:stream/${aws_kinesis_stream.inbound_kinesis.name}"
            ]
          },
          {
            Action   = ["kinesis:ListShards"]
            Effect   = "Allow"
            Resource = "arn:aws:kinesis:*:*:stream/*"
          },
          {
            Action   = ["glue:*"]
            Effect   = "Allow"
            Resource = "*"
          },
          {
            Action   = [
              "logs:*",
              "cloudwatch:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
      })
  }
}

resource "aws_kinesis_stream" "inbound_kinesis" {
  name             = var.inbound_kinesis
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
