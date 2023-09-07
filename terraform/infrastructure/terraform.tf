terraform {
  backend "s3" {
    bucket         = "thsa-link-terraform-state"
    key            = "state/infrastructure.tfstate"
    region         = "us-east-1"
    dynamodb_table = "thsa-link-terraform-locks"
    profile        = "starhie"
  }
}