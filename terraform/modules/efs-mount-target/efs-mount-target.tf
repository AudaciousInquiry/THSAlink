resource "aws_efs_mount_target" "mount-target" {
  file_system_id = var.file_system.id
  security_groups = var.security_groups
  subnet_id = var.subnet_id
}