resource "aws_iam_role" "parkland-inventory-import-xlsx" {
  max_session_duration = "3600"
  name = "${var.environment}-${var.customer}-${var.project_code}-parkland-inventory-import-xlsx-lambda"
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
          "Resource": [aws_secretsmanager_secret.parkland-sftp.arn,aws_secretsmanager_secret.api-authentication.arn],
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
          "Resource": "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": [
            "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
          ]
        }
      ]
    })
  }

  inline_policy {
    name = "CreateNetworkInterface"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "parkland-inventory-import-xlsx-lambda-scheduler-role" {
  name = "${var.environment}-${var.customer}-${var.project_code}-parkland-inventory-import-xlsx-scheduler-role"
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
            "aws:SourceAccount": data.aws_caller_identity.current.account_id
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
            "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.parkland-inventory-import-xlsx.function_name}:*",
            "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.parkland-inventory-import-xlsx.function_name}"
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

resource "aws_lambda_function" "parkland-inventory-import-xlsx" {

  function_name = "${var.environment}-${var.customer}-${var.project_code}-parkland-inventory-import-xlsx"
  role = aws_iam_role.parkland-inventory-import-xlsx.arn
  handler = "ParklandInventoryImport"
  runtime = "java17"
  timeout = 300
  s3_bucket = data.terraform_remote_state.infra.outputs.lambda_deploy_bucket.bucket
  s3_key = module.lambda-jar.s3-file.key
  s3_object_version = module.lambda-jar.s3-file.version_id
  source_code_hash = module.lambda-jar.s3-file.source_hash

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }

  vpc_config {
    security_group_ids = var.security_groups
    //subnet_ids         = var.subnets["primary"]
    subnet_ids = var.subnets["secondary"] // thsa-saner-server-1b
    // ECS run in thsa-saner-server-1a because they need to talk.  This is using thsa-saner-server-1b
    // to get NAT gateway for agreed on external IP.
  }

  environment {
    variables = {
      API_AUTH_SECRET = aws_secretsmanager_secret.api-authentication.name
      PARKLAND_SFTP_SECRET = aws_secretsmanager_secret.parkland-sftp.name
      DOWNLOAD_FILE_NAME = ""
      DOWNLOAD_FILE_PATH = "THSA-SANER/"
      DOWNLOAD_FILE_TYPE = "xlsx"
      API_ENDPOINT = "https://thsa1.sanerproject.org:10440/api/data/file"
      ICU_CODES = "ICU"
    }
  }
}

resource "aws_scheduler_schedule" "parkland-inventory-import-xlsx" {
  name = "${var.environment}-${var.customer}-${var.project_code}-parkland-inventory-import-xlsx-lambda"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(1 days)"

  target {
    arn      = aws_lambda_function.parkland-inventory-import-xlsx.arn
    role_arn = aws_iam_role.parkland-inventory-import-xlsx-lambda-scheduler-role.arn
    input = jsonencode({})
  }
}


resource "aws_lambda_permission" "parkland-inventory-import-xlsx" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.parkland-inventory-import-xlsx.function_name
  principal     = "events.amazonaws.com"
  source_arn = aws_scheduler_schedule.parkland-inventory-import-xlsx.arn
}