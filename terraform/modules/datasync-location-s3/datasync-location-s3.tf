resource "aws_datasync_location_s3" "datasync-location-s3" {
  s3_bucket_arn = var.s3_bucket.arn
  subdirectory = var.subdirectory

  s3_config {
    bucket_access_role_arn = var.access_role.arn
  }

}