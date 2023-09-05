module "ecs-task-datastore" {
  source = "../modules/ecs-task"

  application_code = "datastore"

  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  # TFVARS
  image_repository = var.docker_image_repository
  image_name = var.datastore_docker_image_name
  image_tag = var.datastore_docker_tag
  ecs_task_role = data.terraform_remote_state.infra.outputs.iam-role-arn

  container_environment_file = jsonencode([])
  container_environment = jsonencode([{
    name: "SPRING_CONFIG_LOCATION",
    value: "/datastore/datastore-config.yml"
  }])
  mount_points = jsonencode([{
    sourceVolume: "configuration",
    containerPath: "/datastore/",
    readOnly: false
  }])

  cpu_size = var.datastore_cpu_size
  memory_size = var.datastore_memory_size
  container_port = var.datastore_container_port

  healthcheck = jsonencode({
    "command": [
      "CMD",
      "nc",
      "-vz",
      "-w1",
      "localhost",
      tostring(var.datastore_container_port)
    ],
    "interval": 30,
    "timeout": 10,
    "retries": 5,
    "startPeriod": 300
  })

  volume_filesystem_id = data.terraform_remote_state.infra.outputs.file-system.id
  volume_name = "configuration"
  volume_root_directory = "/datastore"
}

/*
module "ecs-service-datastore" {
  source = "../modules/ecs-service"

  application_code = "datastore"

  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  subnets = var.subnets
  security_groups = var.security_groups

  ecs_cluster_id = data.terraform_remote_state.infra.outputs.ecs_cluster_id
  ecs_task_cqf_arn = module.ecs-task-datastore.arn

  container_port = var.datastore_container_port
  target_group = module.target-group-datastore.target_group

  service_connect = true
  service_discovery_arn = data.terraform_remote_state.infra.outputs.discovery_service_arn
}

module "target-group-datastore" {
  source = "../modules/target-group"

  application_code = "datastore"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn = var.certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port = var.datastore_external_listener_port
  healthcheck_path = "/fhir/metadata"
  container_port = var.datastore_container_port
}
*/