resource "aws_ecs_task_definition" "ecs_task" {
  family = "${var.environment}-${var.customer}-${var.project_code}-${var.application_code}"
  cpu                      = var.cpu_size
  execution_role_arn       = var.ecs_task_role
  memory                   = var.memory_size
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
      cpu_architecture        = "X86_64"
      operating_system_family = "LINUX"
  }

  task_role_arn = var.ecs_task_role

  container_definitions = jsonencode([
{
  cpu : 0,
  environment : jsondecode(var.container_environment),
  environmentFiles : jsondecode(var.container_environment_file),
  essential : true,
  image : "${var.image_repository}/${var.image_name}:${var.image_tag}",
  logConfiguration : {
    "logDriver": "awslogs",
    "options": {
      "awslogs-create-group": "true",
      "awslogs-group": "/${var.environment}-${var.customer}-${var.project_code}-${var.application_code}/",
      "awslogs-region": "us-east-1",
      "awslogs-stream-prefix": "ecs"
    },
    "secretOptions": []
  },
  mountPoints : jsondecode(var.mount_points),
  name : "${var.environment}-${var.customer}-${var.project_code}-${var.application_code}",
  portMappings : [
    {
      "appProtocol": "http",
      "containerPort": var.container_port,
      "hostPort": var.container_port,
      "name": "${var.environment}-${var.customer}-${var.project_code}-${var.application_code}-tcp",
      "protocol": "tcp"
    },
  ],
  ulimits : [],
  volumesFrom : [],
  healthCheck: jsondecode(var.healthcheck)
}
])

  dynamic "volume" {
    for_each = var.volume_filesystem_id != "" ? [1] : []
    content {
      name = var.volume_name

      efs_volume_configuration {
        file_system_id = var.volume_filesystem_id
        root_directory = var.volume_root_directory
      }
    }
  }
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}