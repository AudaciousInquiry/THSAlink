resource "aws_service_discovery_http_namespace" "service-discover-namespace" {
  name        = "${var.environment}-${var.customer}-${var.project_code}"
}

resource "aws_service_discovery_private_dns_namespace" "service-discover-private-dns-namespace" {
  name = "${var.environment}-${var.customer}-${var.project_code}.local"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "service-discovery" {
  name = "${var.environment}-${var.customer}-${var.project_code}"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service-discover-private-dns-namespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}