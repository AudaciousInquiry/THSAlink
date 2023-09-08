resource "aws_s3_bucket" "s3-bucket" {
  bucket = "${var.environment}-${var.customer}-${var.project_code}-${var.bucket_name}"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Description = var.resource_description
    Owner = var.resource_owner
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-bucket-encryption" {
  bucket = aws_s3_bucket.s3-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}