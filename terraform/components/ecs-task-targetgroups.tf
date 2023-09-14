module "target-group-api" {
  source = "../modules/target-group"

  application_code = "api"

  environment  = var.environment
  customer     = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn  = data.terraform_remote_state.infra.outputs.application_certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port    = var.api_external_listener_port
  healthcheck_path = "/fhir/metadata"
  container_port   = var.api_container_port
}

module "target-group-consumer" {
  source = "../modules/target-group"

  application_code = "consumer"

  environment  = var.environment
  customer     = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn  = data.terraform_remote_state.infra.outputs.application_certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port    = var.consumer_external_listener_port
  healthcheck_path = "/fhir/metadata"
  container_port   = var.consumer_container_port
}

module "target-group-cqf" {
  source = "../modules/target-group"

  application_code = "cqf"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn = data.terraform_remote_state.infra.outputs.application_certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port = var.cqf_external_listener_port
  healthcheck_path = "/fhir/metadata"
  container_port = var.cqf_container_port
}

module "target-group-datastore" {
  source = "../modules/target-group"

  application_code = "datastore"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn = data.terraform_remote_state.infra.outputs.application_certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port = var.datastore_external_listener_port
  healthcheck_path = "/fhir/metadata"
  container_port = var.datastore_container_port
}

module "target-group-keycloak" {
  source = "../modules/keycloak-target-group"

  application_code = "keycloak"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn = data.terraform_remote_state.infra.outputs.application_certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port = var.keycloak_external_listener_port
  healthcheck_path = "/health"

  container_port = var.keycloak_container_port
}

module "target-group-web" {
  source = "../modules/target-group"

  application_code = "web"

  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  vpc_id = var.vpc_id

  certificate_arn = data.terraform_remote_state.infra.outputs.application_certificate_arn
  loadbalancer_arn = var.loadbalancer_arn
  listener_port = var.web_external_listener_port
  healthcheck_path = "/"
  container_port = var.web_container_port
}