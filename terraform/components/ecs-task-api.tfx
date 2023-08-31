module "ecs-task-api" {
  source = "../modules/ecs-task"

  application_code = "api"

  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  # TFVARS
  image_repository = var.docker_image_repository
  image_name = var.api_docker_image_name
  image_tag = var.api_docker_tag
  ecs_task_role = data.terraform_remote_state.infra.outputs.iam-role-arn

  container_environment_file = jsonencode([])
  container_environment = jsonencode([{
    name: "SPRING_CONFIG_LOCATION",
    value: "/api/api-config.yml"
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

module "ecs-service-api" {
  source = "../modules/ecs-service"

  application_code = "api"

  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  subnets = var.subnets
  security_groups = var.security_groups

  ecs_cluster_id = data.terraform_remote_state.infra.outputs.ecs_cluster_id
  ecs_task_cqf_arn = module.ecs-task-api.arn

  container_port = var.api_container_port
  target_group = module.target-group-api.target_group

  service_connect = false
}

module "target-group-api" {
  source = "../modules/target-group"

  application_code = "api"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn = var.certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port = var.api_external_listener_port
  healthcheck_path = "/fhir/metadata"

}