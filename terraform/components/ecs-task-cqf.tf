module "ecs-task-cqf" {
  source = "../modules/ecs-task"

  application_code = "cqf"

  aws_region = var.aws_region
  aws_profile = var.aws_profile
  environment = var.environment
  customer = var.customer
  project_code = var.project_code

  # TFVARS
  image_repository = var.docker_image_repository
  image_name = var.cqf_docker_image_name
  image_tag = var.cqf_docker_tag
  ecs_task_role = data.terraform_remote_state.infra.outputs.iam-role-arn

  //value: "arn:aws:s3:::${aws_s3_object.cqf-environment-file.bucket}/${aws_s3_object.cqf-environment-file.key}",
  container_environment_file = jsonencode([
    {
      value: "arn:aws:s3:::${data.terraform_remote_state.infra.outputs.cqf-environment-file.bucket}/${data.terraform_remote_state.infra.outputs.cqf-environment-file.key}"
      type: "s3"
    }
  ])
  container_environment = jsonencode([])

  cpu_size = var.cqf_cpu_size
  memory_size = var.cqf_memory_size
  container_port = var.cqf_container_port

  healthcheck = jsonencode({
    "command": [
      "CMD",
      "nc",
      "-vz",
      "-w1",
      "localhost",
      tostring(var.cqf_container_port)
    ],
    "interval": 30,
    "timeout": 10,
    "retries": 5,
    "startPeriod": 300
  })
  mount_points          = jsonencode([])

  volume_name           = ""
  volume_root_directory = ""
  volume_filesystem_id  = ""
}