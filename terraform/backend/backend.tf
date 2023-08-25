provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.customer}-${var.project_code}-terraform-state"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Description = "S3 bucket to store terraform state for ${var.customer}-${var.project_code}."
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.bucket

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.bucket
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.customer}-${var.project_code}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Description = "DynamoDB to store terraform state for ${var.customer}-${var.project_code}."
  }
}