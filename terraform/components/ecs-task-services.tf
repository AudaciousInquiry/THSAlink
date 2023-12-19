module "ecs-service-api" {
  source = "../modules/ecs-service"

  application_code = "api"

  aws_region = data.aws_region.current.name
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  subnets = var.subnets
  security_groups = var.security_groups

  ecs_cluster_id = data.terraform_remote_state.infra.outputs.ecs_cluster_id
  ecs_task_cqf_arn = module.ecs-task-api.arn

  container_port = var.api_container_port
  target_group = module.target-group-api.target_group

  service_connect = true
  service_discovery_arn = data.terraform_remote_state.infra.outputs.discovery_service_arn
}

module "ecs-service-consumer" {
  source = "../modules/ecs-service"

  application_code = "consumer"

  aws_region = data.aws_region.current.name
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  subnets = var.subnets
  security_groups = var.security_groups

  ecs_cluster_id = data.terraform_remote_state.infra.outputs.ecs_cluster_id
  ecs_task_cqf_arn = module.ecs-task-consumer.arn

  container_port = var.consumer_container_port
  target_group = module.target-group-consumer.target_group

  service_connect = true
  service_discovery_arn = data.terraform_remote_state.infra.outputs.discovery_service_arn
}

module "ecs-service-cqf" {
  source = "../modules/ecs-service"

  application_code = "cqf"

  aws_region = data.aws_region.current.name
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  subnets = var.subnets
  security_groups = var.security_groups

  ecs_cluster_id = data.terraform_remote_state.infra.outputs.ecs_cluster_id
  ecs_task_cqf_arn = module.ecs-task-cqf.arn

  container_port = var.cqf_container_port
  target_group = module.target-group-cqf.target_group

  service_connect = true
  service_discovery_arn = data.terraform_remote_state.infra.outputs.discovery_service_arn
}

module "ecs-service-datastore" {
  source = "../modules/ecs-service"

  application_code = "datastore"

  aws_region = data.aws_region.current.name
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

module "ecs-service-keycloak" {
  source = "../modules/ecs-service"

  application_code = "keycloak"

  aws_region = data.aws_region.current.name
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
  service_discovery_arn = data.terraform_remote_state.infra.outputs.discovery_service_arn
}

module "ecs-service-web" {
  source = "../modules/ecs-service"

  application_code = "web"

  aws_region = data.aws_region.current.name
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  subnets = var.subnets
  security_groups = var.security_groups

  ecs_cluster_id = data.terraform_remote_state.infra.outputs.ecs_cluster_id
  ecs_task_cqf_arn = module.ecs-task-web.arn

  container_port = var.web_container_port
  target_group = module.target-group-web.target_group

  service_connect = false
  service_discovery_arn = data.terraform_remote_state.infra.outputs.discovery_service_arn
}