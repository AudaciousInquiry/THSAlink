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
  environment = var.environment
}

module "datasync-location-efs" {
  source = "../modules/datasync-location-efs"

  depends_on = [module.ecs-configuration-mount-target.target]

  efs-filesystem = module.ecs-configuration-efs.file-system

  // Datasync locations require full subnet & security group ARNs, not just the ID.
  // Since we already have a variables to hold a lists of subnet and security group IDs
  // we are here buildinglists of subnet and security group ARNs.
  // This is a bit of a hack, and make break in the future if AWS changes the layout of the ARN.
  // Right now they contains the AWS Region, AWS Account ID and the subnet ID or security group ID.
  // AWS Region and Account ID are getting pulled ultimately from the provider.tf setup.
  security_groups_arns = [for sg in var.security_groups : "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/${sg}"]
  subnets_arns = [for s in var.subnets : "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/${s}"]

  environment = var.environment
}

module "datasync-log-group" {
  source = "../modules/cloudwatch-log-group"
  name = "${var.environment}-${var.customer}-${var.project_code}-datasync-cloudwatch-log-group"
  environment = var.environment
}

module "configuration-sync-task" {
  source = "../modules/datasync-task"
  destination_location = module.datasync-location-efs.location
  log_group = module.datasync-log-group.group
  name = "${var.environment}-${var.customer}-${var.project_code}-datasync-task"
  source_location = module.datasync-location-s3.location
  environment = var.environment
}