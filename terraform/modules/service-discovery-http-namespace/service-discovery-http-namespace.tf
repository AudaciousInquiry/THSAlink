resource "aws_service_discovery_http_namespace" "service-discover-namespace" {
  name        = "${var.environment}-${var.customer}-${var.project_code}"
}