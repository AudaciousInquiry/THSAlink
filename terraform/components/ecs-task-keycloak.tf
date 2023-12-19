module "ecs-task-keycloak" {
  source = "../modules/keycloak-ecs-task"

  application_code = "keycloak"

  aws_region = data.aws_caller_identity.current.account_id
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  # TFVARS
  //image_repository = "quay.io/keycloak"
  image_repository = var.docker_image_repository
  image_name = var.keycloak_docker_image_name
  image_tag = var.keycloak_docker_tag
  ecs_task_role = data.terraform_remote_state.infra.outputs.iam-role-arn

  container_environment_file = jsonencode([
    {
      value: "arn:aws:s3:::${data.terraform_remote_state.infra.outputs.keycloak-environment-file.bucket}/${data.terraform_remote_state.infra.outputs.keycloak-environment-file.key}"
      type: "s3"
    }
  ])
  container_environment = jsonencode([])

  mount_points = jsonencode([{
    sourceVolume: "configuration",
    containerPath: "/keycloak/",
    readOnly: false
  }])

  cpu_size = var.keycloak_cpu_size
  memory_size = var.keycloak_memory_size
  container_port = var.keycloak_container_port

  healthcheck = jsonencode({
    "command": [
      "CMD",
      "nc",
      "-vz",
      "-w1",
      "localhost",
      tostring(var.keycloak_container_port)
    ],
    "interval": 30,
    "timeout": 10,
    "retries": 5,
    "startPeriod": 300
  })

  volume_filesystem_id = data.terraform_remote_state.infra.outputs.file-system.id
  volume_name = "configuration"
  volume_root_directory = "/keycloak"
}