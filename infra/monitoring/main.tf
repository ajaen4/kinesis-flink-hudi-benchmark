data "aws_iam_policy_document" "metric_pusher_assume_policy" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "push_metric_policy" {

  statement {
    sid       = "pushMetric"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:*"
    ]
  }

  statement {
    sid       = "queryAthena"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "athena:*",
    ]
  }

  statement {
    sid       = "glue"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "glue:*",
    ]
  }

  statement {
    sid       = "queryAthenaFromS3"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:*",
    ]
  }

}

resource "aws_iam_policy" "push_metric_policy" {
  name        = "push-metric-policy"
  path        = "/"
  description = "Allow push metrics to CloudWatch"

  policy = data.aws_iam_policy_document.push_metric_policy.json
}

resource "aws_iam_role" "metric_pusher_lambda_role" {
  name               = "metric-pusher-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.metric_pusher_assume_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_iam_role_policy_attachment" "metric_pusher_lambda_role_attachment" {
  role       = aws_iam_role.metric_pusher_lambda_role.name
  policy_arn = aws_iam_policy.push_metric_policy.arn
}

resource "aws_lambda_function" "metric_pusher_lambda" {

  depends_on = [
    null_resource.build_metric_pusher_image
  ]

  function_name = "metric-pusher-lambda"
  role          = aws_iam_role.metric_pusher_lambda_role.arn
  timeout = 60

  package_type = "Image"
  image_uri = "${aws_ecr_repository.metric_pusher_ecr_repo.repository_url}:${var.image_tag}"

  environment {
    variables = {
      DATABASE_NAME = var.database_name
      TABLE_NAME = var.table_name
    }
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/metric-pusher-lambda"
  retention_in_days = 14
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  function_name = aws_lambda_function.metric_pusher_lambda.function_name
  statement_id  = "CloudWatchInvoke"
  action        = "lambda:InvokeFunction"

  source_arn = aws_cloudwatch_event_rule.every_minute.arn
  principal  = "events.amazonaws.com"
}

resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "every_minute"
  schedule_expression = "cron(*/1 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule = aws_cloudwatch_event_rule.every_minute.name
  arn  = aws_lambda_function.metric_pusher_lambda.arn
}

resource "aws_ecr_repository" "metric_pusher_ecr_repo" {
  name                 = "metric-pusher-ecr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "build_metric_pusher_image" {

  depends_on = [
    aws_ecr_repository.metric_pusher_ecr_repo
  ]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = (templatefile("${path.module}/build_image.tpl", {
      aws_account_id = var.aws_account_id,
      region = var.aws_region_name,
      repository_url = aws_ecr_repository.metric_pusher_ecr_repo.repository_url,
      image_tag  = var.image_tag,
      function_path = "monitoring/functions/metric_pusher"
      }
    ))
  }
}
