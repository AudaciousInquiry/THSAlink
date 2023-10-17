#resource "aws_iam_role" "refresh-patient-list" {
#  max_session_duration = "3600"
#  name = "${var.environment}-${var.customer}-${var.project_code}-refresh-patient-list-lambda"
#  path = "/service-role/"
#
#  assume_role_policy = jsonencode({
#    "Statement": [
#      {
#        "Action": "sts:AssumeRole",
#        "Effect": "Allow",
#        "Principal": {
#          "Service": "lambda.amazonaws.com"
#        }
#      }
#    ],
#    "Version": "2012-10-17"
#  })
#
#  inline_policy {
#    name = "ReadExpungeSecret"
#    policy = jsonencode({
#      "Version": "2012-10-17",
#      "Statement": [
#        {
#          "Action": [
#            "secretsmanager:GetSecretValue",
#            "secretsmanager:DescribeSecret"
#          ],
#          "Effect": "Allow",
#          "Resource": [
#            aws_secretsmanager_secret.api-authentication.arn,
#            aws_secretsmanager_secret.parkland-epic-auth.arn,
#            aws_secretsmanager_secret.parkland-epic-query.arn,
#            aws_secretsmanager_secret.parkland-refresh-patient-list.arn
#          ]
#          "Sid": "VisualEditor0"
#        }
#      ]
#    })
#  }
#
#  // TODO - name the actual lambda in resource - getting cyclical error currently.
#  inline_policy {
#    name = "CreateLogGroup"
#    policy = jsonencode({
#      "Version": "2012-10-17",
#      "Statement": [
#        {
#          "Effect": "Allow",
#          "Action": "logs:CreateLogGroup",
#          "Resource": "arn:aws:logs:us-east-1:${var.aws_account}:*"
#        },
#        {
#          "Effect": "Allow",
#          "Action": [
#            "logs:CreateLogStream",
#            "logs:PutLogEvents"
#          ],
#          "Resource": [
#            "arn:aws:logs:us-east-1:${var.aws_account}:log-group:/aws/lambda/*"
#          ]
#        }
#      ]
#    })
#  }
#}
#
#resource "aws_iam_role" "refresh-patient-list-lambda-scheduler-role" {
#  name = "${var.environment}-${var.customer}-${var.project_code}-refresh-patient-list-scheduler-role"
#  assume_role_policy = jsonencode({
#    "Version": "2012-10-17",
#    "Statement": [
#      {
#        "Effect": "Allow",
#        "Principal": {
#          "Service": "scheduler.amazonaws.com"
#        },
#        "Action": "sts:AssumeRole",
#        "Condition": {
#          "StringEquals": {
#            "aws:SourceAccount": var.aws_account
#          }
#        }
#      }
#    ]
#  })
#
#  max_session_duration = "3600"
#
#  inline_policy {
#    name = "${var.environment}-${var.customer}-${var.project_code}-RunLambda"
#    policy = jsonencode({
#      "Version": "2012-10-17",
#      "Statement": [
#        {
#          "Effect": "Allow",
#          "Action": [
#            "lambda:InvokeFunction"
#          ],
#          "Resource": [
#            "arn:aws:lambda:us-east-1:${var.aws_account}:function:${aws_lambda_function.refresh-patient-list.function_name}:*",
#            "arn:aws:lambda:us-east-1:${var.aws_account}:function:${aws_lambda_function.refresh-patient-list.function_name}"
#          ]
#        }
#      ]
#    })
#  }
#  tags = {
#    Environment = var.environment,
#    CreatedBy = "terraform"
#  }
#}
#
#resource "aws_lambda_function" "refresh-patient-list" {
#
#  function_name = "${var.environment}-${var.customer}-${var.project_code}-refresh-patient-list"
#  role = aws_iam_role.refresh-patient-list.arn
#  handler = "RefreshPatientList"
#  runtime = "java17"
#  timeout = 300
#  s3_bucket = data.terraform_remote_state.infra.outputs.lambda_deploy_bucket.bucket
#  s3_key = module.lambda-jar.s3-file.key
#  s3_object_version = module.lambda-jar.s3-file.version_id
#  source_code_hash = module.lambda-jar.s3-file.source_hash
#
#  tags = {
#    Environment = var.environment,
#    CreatedBy = "terraform"
#  }
#
#  environment {
#    variables = {
#      API_AUTH_SECRET = aws_secretsmanager_secret.api-authentication.name
#      API_ENDPOINT = "https://thsa1.sanerproject.org:10440/api/poi/fhir/PatientList"
#      PARKLAND_EPIC_AUTH_SECRET = aws_secretsmanager_secret.parkland-epic-auth.name
#      PARKLAND_EPIC_QUERY_SECRET = aws_secretsmanager_secret.parkland-epic-query.name
#      PARKLAND_REFRESH_PATIENT_SECRET = aws_secretsmanager_secret.parkland-refresh-patient-list.name
#    }
#  }
#}
#
#resource "aws_scheduler_schedule" "refresh-patient-list" {
#  name = "${var.environment}-${var.customer}-${var.project_code}-refresh-patient-list-lambda"
#  group_name = "default"
#
#  flexible_time_window {
#    mode = "OFF"
#  }
#
#  schedule_expression = "cron(0 13,1 ? * * *)"
#
#  target {
#    arn      = aws_lambda_function.refresh-patient-list.arn
#    role_arn = aws_iam_role.refresh-patient-list-lambda-scheduler-role.arn
#    input = jsonencode({})
#  }
#}
#
#
#resource "aws_lambda_permission" "refresh-patient-list" {
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.refresh-patient-list.function_name
#  principal     = "events.amazonaws.com"
#  source_arn = aws_scheduler_schedule.refresh-patient-list.arn
#}
