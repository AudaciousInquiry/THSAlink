output http_namespace_id {
  value = aws_service_discovery_http_namespace.service-discover-namespace.id
}

output private_dns_namespace_id {
  value = aws_service_discovery_private_dns_namespace.service-discover-private-dns-namespace.id
}

output discovery_service_arn {
  value = aws_service_discovery_service.service-discovery.arn
}