resource "aws_cloudwatch_log_group" "cloudwatch-group" {
  name = var.name
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}