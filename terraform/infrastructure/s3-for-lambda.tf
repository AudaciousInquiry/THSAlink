module "lambda-deploy-s3" {
  source = "../modules/s3"
  bucket_name = "lambda-deploy"
  customer = var.customer
  environment = var.environment
  project_code = var.project_code
  resource_description = "S3 Bucket For THSALink Lambda Deployment"
  resource_owner = var.resource_owner
}