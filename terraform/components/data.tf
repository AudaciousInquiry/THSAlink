data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket         = "thsa-link-terraform-state"
    key            = "state/dev.infrastructure.tfstate"
    region         = "us-east-1"
    dynamodb_table = "thsa-link-terraform-locks"
    profile        = "starhie"
  }
}