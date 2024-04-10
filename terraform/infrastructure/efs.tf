module "ecs-configuration-efs" {
  source = "../modules/efs-file-system"
  name   = "${var.environment}-${var.customer}-${var.project_code}-ecs-configuration"
  environment = var.environment
}

module "ecs-configuration-mount-target" {
  source          = "../modules/efs-mount-target"
  file_system     = module.ecs-configuration-efs.file-system
  security_groups = var.security_groups
  subnet_id       = element(var.subnets, 1) # TODO - need to revisit this if we ever ACTUALLY start using > 1 subnet
}

module "ecs-configuraton-mount-target-2" {
  source          = "../modules/efs-mount-target"
  file_system     = module.ecs-configuration-efs.file-system
  security_groups = var.security_groups
  subnet_id       = "subnet-0bbbe165bb6013ed4"
}