#module "ecs-task-parkland-csv" {
#  source = "../modules/ecs-task-cli"
#
#  application_code = "parkland-csv"
#
#  environment = var.environment
#  customer = var.customer
#  project_code = var.project_code
#
#  # TFVARS
#  image_repository = var.docker_image_repository
#  image_name = "thsa-link-cli-parkland-csv"
#  image_tag = var.default_docker_tag
#  ecs_task_role = data.terraform_remote_state.infra.outputs.iam-role-arn
#
#  container_environment_file = jsonencode([])
#  container_environment = jsonencode([])
#
#  cpu_size = var.default_cpu_size
#  memory_size = var.default_memory_size
#
#  mount_points = jsonencode([{
#    sourceVolume: "cli",
#    containerPath: "/cli",
#    readOnly: false
#  }])
#
#  volume_filesystem_id = data.terraform_remote_state.infra.outputs.file-system.id
#  volume_name = "cli"
#  volume_root_directory = "/cli"
#}
#
#/*
#resource "aws_scheduler_schedule" "parkland-csv-schedule" {
#  name = "${var.environment}-${var.customer}-${var.project_code}-parkland-csv"
#  group_name = "default"
#
#  flexible_time_window {
#    mode = "OFF"
#  }
#
#  schedule_expression = "rate(1 days)"
#
#  target {
#    arn      = data.terraform_remote_state.infra.outputs.ecs_cluster_arn
#    role_arn = aws_iam_role.scheduler-role.arn
#    ecs_parameters {
#      task_definition_arn = module.ecs-task-parkland-csv.arn
#      task_count = "1"
#      launch_type = "FARGATE"
#      network_configuration {
#        subnets = var.subnets["primary"]
#        security_groups = var.security_groups
#        assign_public_ip = false
#      }
#      platform_version = "LATEST"
#      enable_execute_command = false
#      enable_ecs_managed_tags = true
#    }
#  }
#}
#*/