module "lambda-jar" {
  source = "../modules/s3-file"
  file-name = "link-lambda-0.0.1.jar"
  file-path = "../../link-lambda/target/"
  s3-bucket = data.terraform_remote_state.infra.outputs.lambda_deploy_bucket
  environment = var.environment
}