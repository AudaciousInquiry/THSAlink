# CREATE BUCKET TO HOLD ENVIRONMENT / SPRING BOOT CONFIGURATION FILES
module "ecs-configuration-s3" {
  source = "../modules/s3"
  bucket_name = "ecs-configuration"
  customer = var.customer
  environment = var.environment
  project_code = var.project_code
  resource_description = "S3 Bucket For THSALink ECS Configurations"
  resource_owner = var.resource_owner
}

# Upload CQF Environment File to S3 Bucket
module "cqf-environment-file" {
  source = "../modules/s3-file"
  file-name = "thsa-link-cqf.env"
  file-path = "../environment-files/"
  s3-bucket = module.ecs-configuration-s3.s3_bucket
}

# Upload DataStore Spring Boot Configuration File to S3 Bucket
module "datastore-configuration-file" {
  source = "../modules/s3-file"
  file-name = "datastore/datastore-config.yml"
  file-path = "../environment-files/"
  s3-bucket = module.ecs-configuration-s3.s3_bucket
}

# Upload Consumer Spring Boot Configuration File to S3 Bucket
module "consumer-configuration-file" {
  source = "../modules/s3-file"
  file-name = "consumer/consumer-config.yml"
  file-path = "../environment-files/"
  s3-bucket = module.ecs-configuration-s3.s3_bucket
}

# Upload API Spring Boot Configuration File to S3 Bucket
module "api-configuration-file" {
  source = "../modules/s3-file"
  file-name = "api/api-config.yml"
  file-path = "../environment-files/"
  s3-bucket = module.ecs-configuration-s3.s3_bucket
}

# Upload local.json File Required By NGINX on Web Component
module "web-configuration-file" {
  source = "../modules/s3-file"
  file-name = "web/local.json"
  file-path = "../environment-files/"
  s3-bucket = module.ecs-configuration-s3.s3_bucket
}

module "web-configuration-file2" {
  source = "../modules/s3-file"
  file-name = "web/config.json"
  file-path = "../environment-files/"
  s3-bucket = module.ecs-configuration-s3.s3_bucket
}