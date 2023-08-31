module "ecs-task-keycloak" {
  source = "../modules/keycloak-ecs-task"

  application_code = "keycloak"

  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  # TFVARS
  image_repository = "quay.io/keycloak"
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
  /*
  container_environment = jsonencode([
    {
      name: "KC_HOSTNAME",
      value: "thsa1.sanerproject.org"
    },
    {
      name: "KC_DB",
      value: "postgres"
    },
    {
      name: "KC_DB_URL",
      value: "jdbc:postgresql://thsa-db-cluster-1.cluster-c9ay9pkcn7ra.us-east-1.rds.amazonaws.com:5432/keycloak_20?ssl=true&sslmode=require"
    },
    {
      name: "KC_DB_USERNAME",
      value: "keycloak_20"
    },
    {
      name: "KC_DB_PASSWORD",
      value: "Frays8^Pronto^Obtrusive"
    },
    {
      name: "KC_HTTPS_CERTIFICATE_FILE",
      value: "/keycloak/EXP-2023-Sept-07.thsa1.sanerproject.org.crt.pem"
    },
    {
      name: "KC_HTTPS_CERTIFICATE_KEY_FILE",
      value: "/keycloak/EXP-2023-Sept-07.thsa1.sanerproject.org.key.pem"
    },

    {
      name: "KC_HEALTH_ENABLED",
      value: "true"
    },
    {
      name: "KC_PROXY",
      value: "passthrough"
    },
    {
      name: "KC_HOSTNAME_ADMIN",
      value: "thsa1.sanerproject.org"
    },
    {
      name: "KC_HOSTNAME_PORT",
      value: "12443"
    },
    {
      name: "KC_HOSTNAME_STRICT",
      value: "false"
    }
  ])
  */
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

module "ecs-service-keycloak" {
  source = "../modules/ecs-service"

  application_code = "keycloak"

  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  subnets = var.subnets
  security_groups = var.security_groups

  ecs_cluster_id = data.terraform_remote_state.infra.outputs.ecs_cluster_id
  ecs_task_cqf_arn = module.ecs-task-keycloak.arn

  container_port = var.keycloak_container_port
  target_group = module.target-group-keycloak.target_group

  service_connect = false
}

module "target-group-keycloak" {
  source = "../modules/keycloak-target-group"

  application_code = "keycloak"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn = var.certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port = var.keycloak_external_listener_port
  healthcheck_path = "/health"

  container_port = var.keycloak_container_port
}