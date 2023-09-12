resource "aws_iam_role" "iam-role" {
  name = "${var.environment}-${var.customer}-${var.project_code}-ecsTaskExecuteRole"
  assume_role_policy = jsonencode({
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "ecs-tasks.amazonaws.com",
            "datasync.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  max_session_duration = "3600"
  path                 = "/"

  // Add inline policy allowing this role to create Cloudwatch Log Groups
  // otherwise ECS task failure.
  inline_policy {
    name = "CloudWatchCreateLogs"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": "logs:CreateLogGroup",
          "Resource": "*"
        }
      ]
    })
  }

  // Add inline policy allowing this role to list the s3 bucket
  // that contains the configuration files.
  inline_policy {
    name = "S3BucketPolicy-${module.ecs-configuration-s3.s3_bucket.bucket}"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": ["s3:GetBucketLocation","s3:ListBucket"],
          "Resource": "${module.ecs-configuration-s3.s3_bucket.arn}"
        }
      ]
    })
  }

  // Add inline policy allowing this role to get objects in
  // the s3 bucket that contains the configuration files.
  inline_policy {
    name = replace("S3FilePolicy-${module.ecs-configuration-s3.s3_bucket.bucket}-allfiles","/","")
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${module.ecs-configuration-s3.s3_bucket.bucket}/*"
        }
      ]
    })
  }
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.iam-role.id
}