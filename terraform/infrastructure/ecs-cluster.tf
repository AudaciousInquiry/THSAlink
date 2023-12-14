module "ecs-cluster" {
  source = "../modules/ecs-cluster"

  environment = var.environment
  project_code = var.project_code
  customer = var.customer
}