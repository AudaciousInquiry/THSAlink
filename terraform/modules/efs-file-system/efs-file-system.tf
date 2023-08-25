resource "aws_efs_file_system" "efs-file-system" {
  creation_token = var.name
  encrypted = "true"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  performance_mode = "generalPurpose"
  provisioned_throughput_in_mibps = "0"
  throughput_mode = "elastic"
}