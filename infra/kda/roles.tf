resource "aws_iam_role" "flink_app_role" {
  name = "${local.full_name}"

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
          Action = ["kinesis:*"]
          Effect = "Allow"
          Resource = [
            "arn:aws:kinesis:*:*:stream/${var.source_stream_name}"
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
          Action = [
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

