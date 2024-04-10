provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

# Import statements for S3 and DynamoDB items.
# These are ONLY necessary when initially setting up the
# backend state on a NEW machine.  Once you have imported
# comment these back out.
# The id for the S3 items is the name of the S3 bucket which
# has been setup in AWS.
# The id for the DynamoDB is similarly the name of the DynamoDB
# which has been setup in AWS.
/*
import {
  to = aws_s3_bucket.terraform_state
  id = "${var.customer}-${var.project_code}-terraform-state"
}
import {
  to = aws_s3_bucket_public_access_block.terraform_state
  id = "thsa-link-terraform-state"
}
import {
  to = aws_s3_bucket_server_side_encryption_configuration.terraform_state
  id = "thsa-link-terraform-state"
}
import {
  to = aws_s3_bucket_versioning.terraform_state
  id = "thsa-link-terraform-state"
}
import {
  to = aws_dynamodb_table.terraform_locks
  id = "thsa-link-terraform-locks"
}
*/

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