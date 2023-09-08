output "file-system" {
  value = module.ecs-configuration-efs.file-system
}

output "iam-role-arn" {
  value = aws_iam_role.iam-role.arn
}

output "ecs_cluster_id" {
  value = module.ecs-cluster.ecs_cluster_id
}

output "ecs_cluster_arn" {
  value = module.ecs-cluster.ecs_cluster_arn
}

output "cqf-environment-file" {
  value = module.cqf-environment-file.s3-file
}

output "keycloak-environment-file" {
  value = module.keycloak-environment-file.s3-file
}

output "discovery_service_arn" {
  value = module.service-discover-namespace.discovery_service_arn
}

output "application_certificate_arn" {
  value = aws_acm_certificate.thsa1_sanerproject_org_exp_2024.arn
}