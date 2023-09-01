resource "aws_s3_object" "s3-file" {
  bucket = var.s3-bucket.id
  key    = var.file-name
  source = "${var.file-path}${var.file-name}"
  etag = filemd5("${var.file-path}${var.file-name}")
}