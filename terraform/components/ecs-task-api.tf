module "ecs-task-api" {
  source = "../modules/ecs-task"

  application_code = "api"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  # TFVARS
  image_repository = var.docker_image_repository
  image_name = var.api_docker_image_name
  image_tag = var.image["api"].tag != "" ? var.image["api"].tag : var.image["default"].tag
  ecs_task_role = data.terraform_remote_state.infra.outputs.iam-role-arn

  container_environment_file = jsonencode([])
  container_environment = jsonencode([{
    name: "SPRING_CONFIG_LOCATION",
    value: "/api/api-config.yml"
  },{
    name: "api.data-store.base-url",
    value: "http://dev-thsa-link-datastore-tcp.dev-thsa-link:8080/fhir"
  }])
  mount_points = jsonencode([{
    sourceVolume: "configuration",
    containerPath: "/api/",
    readOnly: false
  }])

  cpu_size = var.api_cpu_size
  memory_size = var.api_memory_size
  container_port = var.api_container_port

  healthcheck = jsonencode({
    "command": [
      "CMD",
      "nc",
      "-vz",
      "-w1",
      "localhost",
      tostring(var.api_container_port)
    ],
    "interval": 30,
    "timeout": 10,
    "retries": 5,
    "startPeriod": 300
  })

  volume_filesystem_id = data.terraform_remote_state.infra.outputs.file-system.id
  volume_name = "configuration"
  volume_root_directory = "/api"
}