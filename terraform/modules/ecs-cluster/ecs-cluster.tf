resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.environment}-${var.customer}-${var.project_code}-cluster"

    setting {
        name  = "containerInsights"
        value = "enabled"
    }

    configuration {
        execute_command_configuration {
            logging = "DEFAULT"
        }
    }
    tags = {
        Environment = var.environment,
        CreatedBy = "terraform"
    }
}