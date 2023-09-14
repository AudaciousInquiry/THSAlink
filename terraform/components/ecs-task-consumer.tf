module "ecs-task-consumer" {
  source = "../modules/ecs-task"

  application_code = "consumer"

  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  # TFVARS
  image_repository = var.docker_image_repository
  image_name = var.consumer_docker_image_name
  image_tag = var.consumer_docker_tag
  ecs_task_role = data.terraform_remote_state.infra.outputs.iam-role-arn

  container_environment_file = jsonencode([])
  container_environment = jsonencode([{
    name: "SPRING_CONFIG_LOCATION",
    value: "/consumer/consumer-config.yml"
  }])
  mount_points = jsonencode([{
    sourceVolume: "configuration",
    containerPath: "/consumer/",
    readOnly: false
  }])

  cpu_size = var.consumer_cpu_size
  memory_size = var.consumer_memory_size
  container_port = var.consumer_container_port

  healthcheck = jsonencode({
    "command": [
      "CMD",
      "nc",
      "-vz",
      "-w1",
      "localhost",
      tostring(var.consumer_container_port)
    ],
    "interval": 30,
    "timeout": 10,
    "retries": 5,
    "startPeriod": 300
  })

  volume_filesystem_id = data.terraform_remote_state.infra.outputs.file-system.id
  volume_name = "configuration"
  volume_root_directory = "/consumer"
}