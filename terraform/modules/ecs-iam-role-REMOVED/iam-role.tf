resource "aws_iam_role" "iam-role" {
  name = "${var.environment}-${var.customer}-${var.project_code}-${var.role_name}"
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
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.iam-role.id
}