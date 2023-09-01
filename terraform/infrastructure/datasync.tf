/*
  We need to get Spring Boot configuration files onto EFS so that they can be referenced
  by ECS Tasks.

  There's not easy way, it seems, to do this via Terraform directly but is easy to copy
  files to S3 via Terraform.

  So we'll copy the files to S3, then setup a DataSync task to copy from S3 to EFS.  The
  last part of this file (the null_resource) kicks off the created task via aws cli.
*/
module "datasync-location-s3" {
  source = "../modules/datasync-location-s3"
  access_role = aws_iam_role.iam-role
  s3_bucket = module.ecs-configuration-s3.s3_bucket
  subdirectory = "/"
}

module "datasync-location-efs" {
  source = "../modules/datasync-location-efs"

  depends_on = [module.ecs-configuraton-mount-target.target]

  efs-filesystem = module.ecs-configuration-efs.file-system
  security_groups_arns = var.security_groups_arns
  subnets_arns = var.subnets_arns
}

module "datasync-log-group" {
  source = "../modules/cloudwatch-log-group"
  name = "${var.environment}-${var.customer}-${var.project_code}-datasync-cloudwatch-log-group"
}

module "configuration-sync-task" {
  source = "../modules/datasync-task"
  destination_location = module.datasync-location-efs.location
  log_group = module.datasync-log-group.group
  name = "${var.environment}-${var.customer}-${var.project_code}-datasync-task"
  source_location = module.datasync-location-s3.location
}

/*
resource "null_resource" "trigger-task" {
  depends_on = [module.datasync-location-efs, module.datasync-location-s3, module.configuration-sync-task]
  provisioner "local-exec" {
    command = <<EOT
      echo "Triggering DataSync Task...."
      aws datasync start-task-execution --profile ${var.aws_profile} --task-arn ${module.configuration-sync-task.task.arn}
    EOT
  }
}
*/