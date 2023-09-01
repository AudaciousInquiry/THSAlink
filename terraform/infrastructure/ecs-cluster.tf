module "ecs-cluster" {
  source = "../modules/ecs-cluster"
  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  project_code = var.project_code
  customer = var.customer
}