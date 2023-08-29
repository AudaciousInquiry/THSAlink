output "file-system" {
  value = module.ecs-configuration-efs.file-system
}

output "iam-role-arn" {
  value = aws_iam_role.iam-role.arn
}

output "ecs_cluster_id" {
  value = module.ecs-cluster.ecs_cluster_id
}

output "cqf-environment-file" {
  value = module.cqf-environment-file.s3-file
}

output "keycloak-environment-file" {
  value = module.keycloak-environment-file.s3-file
}