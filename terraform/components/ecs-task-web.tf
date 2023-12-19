module "ecs-task-web" {
  source = "../modules/ecs-task"

  application_code = "web"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  # TFVARS
  image_repository = var.docker_image_repository
  image_name = var.web_docker_image_name
  image_tag = var.web_docker_tag
  ecs_task_role = data.terraform_remote_state.infra.outputs.iam-role-arn

  container_environment_file = jsonencode([])
  container_environment = jsonencode([])
  mount_points = jsonencode([{
    sourceVolume: "configuration",
    containerPath: "/usr/share/nginx/html/assets/configuration/",
    readOnly: false
  }])

  cpu_size = var.web_cpu_size
  memory_size = var.web_memory_size
  container_port = var.web_container_port

  healthcheck = jsonencode({
    "command": [
      "CMD-SHELL",
      "curl -f http://localhost:${tostring(var.web_container_port)}/ || exit 1"
    ],
    "interval": 30,
    "timeout": 10,
    "retries": 5,
    "startPeriod": 300
  })

  volume_filesystem_id = data.terraform_remote_state.infra.outputs.file-system.id
  volume_name = "configuration"
  volume_root_directory = "/web"
}