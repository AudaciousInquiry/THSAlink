resource "aws_datasync_task" "datasync-task" {
  destination_location_arn = var.destination_location.arn
  source_location_arn = var.source_location.arn
  name = var.name
  cloudwatch_log_group_arn = var.log_group.arn

  options {
    log_level = "TRANSFER"
    verify_mode = "NONE"
    transfer_mode = "ALL"
  }
  schedule {
    schedule_expression = "rate(1 day)"
  }
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}