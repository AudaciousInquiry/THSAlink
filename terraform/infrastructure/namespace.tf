module "service-discover-namespace" {
  source = "../modules/service-discovery-http-namespace"
  customer = var.customer
  environment = var.environment
  project_code = var.project_code
}