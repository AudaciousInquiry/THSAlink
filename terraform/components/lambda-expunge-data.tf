resource "aws_secretsmanager_secret" "expunge-data" {
  name = "${var.environment}-${var.customer}-${var.project_code}-expunge-data"
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "expunge-data" {
  secret_id = aws_secretsmanager_secret.expunge-data.id
  secret_string = file("../environment-files/expunge-data/expunge-data-secret.json")
}

module "expunge-data-jar" {
  source = "../modules/s3-file"
  file-name = "link-lambda-0.0.1.jar"
  file-path = "../../link-lambda/target/"
  s3-bucket = data.terraform_remote_state.infra.outputs.lambda_deploy_bucket
  environment = var.environment
}

resource "aws_iam_role" "expunge-data" {
  max_session_duration = "3600"
  name = "${var.environment}-${var.customer}-${var.project_code}-expunge-data-lambda"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ],
    "Version": "2012-10-17"
  })

  inline_policy {
    name = "ReadExpungeSecret"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ],
          "Effect": "Allow",
          "Resource": aws_secretsmanager_secret.expunge-data.arn,
          "Sid": "VisualEditor0"
        }
      ]
    })
  }

  // TODO - name the actual lambda in resource - getting cyclical error currently.
  inline_policy {
    name = "CreateLogGroup"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "logs:CreateLogGroup",
          "Resource": "arn:aws:logs:us-east-1:${var.aws_account}:*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": [
            "arn:aws:logs:us-east-1:${var.aws_account}:log-group:/aws/lambda/*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role" "expunge-data-lambda-scheduler-role" {
  name = "${var.environment}-${var.customer}-${var.project_code}-expunge-data-scheduler-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "scheduler.amazonaws.com"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "aws:SourceAccount": var.aws_account
          }
        }
      }
    ]
  })

  max_session_duration = "3600"

  inline_policy {
    name = "${var.environment}-${var.customer}-${var.project_code}-RunLambda"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "lambda:InvokeFunction"
          ],
          "Resource": [
            "arn:aws:lambda:us-east-1:${var.aws_account}:function:${aws_lambda_function.expunge-data.function_name}:*",
            "arn:aws:lambda:us-east-1:${var.aws_account}:function:${aws_lambda_function.expunge-data.function_name}"
          ]
        }
      ]
    })
  }
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lambda_function" "expunge-data" {

  function_name = "${var.environment}-${var.customer}-${var.project_code}-expunge-data"
  role = aws_iam_role.expunge-data.arn
  handler = "ExpungeData"
  runtime = "java17"
  timeout = 300
  s3_bucket = data.terraform_remote_state.infra.outputs.lambda_deploy_bucket.bucket
  s3_key = module.expunge-data-jar.s3-file.key

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }

  environment {
    variables = {
      EXPUNGE_API_URL = "https://thsa1.sanerproject.org:10440/api/data/expunge"
      SECRET_NAME = aws_secretsmanager_secret.expunge-data.name
    }
  }
}

/*
// reverting to ECS task to test something....
resource "aws_scheduler_schedule" "expunge-data" {
  name = "${var.environment}-${var.customer}-${var.project_code}-expunge-data-lambda"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(45 minutes)"

  target {
    arn      = aws_lambda_function.expunge-data.arn
    role_arn = aws_iam_role.expunge-data-lambda-scheduler-role.arn
    input = jsonencode({})
  }
}


resource "aws_lambda_permission" "expunge-data" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.expunge-data.function_name
  principal     = "events.amazonaws.com"
  source_arn = aws_scheduler_schedule.expunge-data.arn
}
*/