resource "aws_iam_role" "cli-scheduler-role" {
  name = "${var.environment}-${var.customer}-${var.project_code}-schedulerRole"
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
    name = "${var.environment}-${var.customer}-${var.project_code}-RunTask"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ecs:RunTask"
          ],
          "Resource": [
            "arn:aws:ecs:us-east-1:${data.aws_caller_identity.current.account_id}:task-definition/*"
          ],
          "Condition": {
            "ArnLike": {
              "ecs:cluster": "${data.terraform_remote_state.infra.outputs.ecs_cluster_arn}"
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": [
            "*"
          ],
          "Condition": {
            "StringLike": {
              "iam:PassedToService": "ecs-tasks.amazonaws.com"
            }
          }
        }
      ]
    })
  }

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}