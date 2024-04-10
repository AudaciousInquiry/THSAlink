resource "aws_datasync_location_efs" "datasync-location-efs" {
  //depends_on = [aws_efs_mount_target.efs-configuration-files-mount-target]
  efs_file_system_arn = var.efs-filesystem.arn
  ec2_config {
    security_group_arns = var.security_groups_arns
    subnet_arn = element(var.subnets_arns, 1)
  }
  in_transit_encryption = "TLS1_2"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}