resource "aws_athena_workgroup" "hudi_json_benchmark" {
  name = var.glue_database_name 

  configuration {
    engine_version {
      selected_engine_version = "Athena engine version 3"
    }
    result_configuration {
      output_location = "s3://${var.artifacts_bucket_name}/athena/"
    }
  }
}

resource "aws_glue_catalog_database" "hudi_json" {
  name = var.glue_database_name 
} 

resource "aws_glue_crawler" "json_table" {
  database_name = aws_glue_catalog_database.hudi_json.name
  name          = "flink_json_table"
  role          = aws_iam_role.json_crawler.arn

  s3_target {
    path = "s3://${module.kda_json.output_bucket}/table_json"
  }
}

resource "aws_iam_role" "json_crawler" {
  name = "json_table_crawler" 

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })
  
  managed_policy_arns = [
    data.aws_iam_policy.glue_service.arn,
    data.aws_iam_policy.s3_access.arn,
  ]
  
}

data "aws_iam_policy" "glue_service" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy" "s3_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
