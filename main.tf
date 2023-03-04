resource "aws_s3_bucket" "hudipractica" {
  bucket = "flink-hudi-practica"

}

#resource "aws_s3_object" "hudipracticafiles" {
#  bucket = aws_s3_bucket.hudipractica.bucket
#  key    = "hudipracticafiles"
#}

data "archive_file" "s3_zip" {                                                                                                                                                                                   
  type        = "zip"                                                                                                                                                                                                
  source_dir  = "flink-app"                                                                                                                                                                                         
  output_path = "myapp.zip"                                                                                                                                                                         
} 

resource "random_string" "myapp" {
  length           = 4
  special          = false
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.hudipractica.bucket
  #key    = "myapp-${random_string.myapp.result}.zip"
  key = join("-",["myapp","${substr(sha256(data.archive_file.s3_zip.output_base64sha256),0,4)}.zip"])
  source = "${data.archive_file.s3_zip.output_path}"
}

#resource "aws_s3_object" "hudipracticaflink" {
#  bucket = aws_s3_bucket.hudipractica.bucket
#  key    = "myapp" #.hash to set a dynamic name in the UI
#  source = "flink-s.jar"
#}

resource "aws_cloudwatch_log_group" "hudipracticaflink" {
  name = "flink-hudi-practica"
}

resource "aws_cloudwatch_log_stream" "hudipracticaflink" {
  name           = "flink-hudi-practica"
  log_group_name = aws_cloudwatch_log_group.hudipracticaflink.name
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
          #identifiers = ["kinesisanalytics.amazonaws.com"]
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
  inline_policy {
    name = "cloudwatch-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["cloudwatch:*", "logs:*"]
            Effect   = "Allow"
            Resource = [
              "*"
            ]
          },
        ]
      })
  }


  tags = {
    tag-key = "tag-value"
  }
}

variable test_jars {
  type = list
  default = ["lib/flink-sql-connector-kinesis-1.15.2.jar", "lib/fake_flink.jar"]
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
          #file_key   = "myapp.zip"
          file_key   = aws_s3_object.app_zip.key
        }
      }

      code_content_type = "ZIPFILE"
    }

    environment_properties {
      property_group {
        property_group_id = "consumer.config.0"
        property_map = {
          "aws.region" = "eu-west-1"
          #"aws.input_property_mapregion" = "eu-west-1"
          #"AggregationEnabled" =  "false"
          "input.stream.name" = "kinesis-flink-hudi-stream"
          #"flink.inputstream.initpos" = "LATEST"
          "scan.stream.initpos" = "LATEST"
        }
      }  
      property_group {
        property_group_id = "kinesis.analytics.flink.run.options"
        property_map = {
          
          "python" = "streaming_file_sink.py"
          "jarfile" = "lib/combined-1.jar"
          #"pyArchives" = "lib_test/jar_zip.zip"
          #"jarfile" = "lib_test/jar_zip.jar"
          #"jarfile" = var.test_jars[*]
        }
      }
      property_group {
        property_group_id = "sink.config.0"
        property_map = {
          "output.bucket.name" = "flink-hudi-practica"
        }
      }
    }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type = "CUSTOM"
        checkpointing_enabled = true
        checkpoint_interval = 5000
      }

      monitoring_configuration {
        configuration_type = "CUSTOM"
        log_level          = "DEBUG"
        metrics_level      = "TASK"
      }

      parallelism_configuration {
        auto_scaling_enabled = true
        configuration_type   = "CUSTOM"
        parallelism          = 1
        parallelism_per_kpu  = 1
      }
    }
  }
  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.hudipracticaflink.arn
  }
}