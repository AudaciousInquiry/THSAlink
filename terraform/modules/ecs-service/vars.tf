variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "customer" {
  type = string
}

variable "project_code" {
  type = string
}

variable "application_code" {
  type = string
}

variable ecs_cluster_id {
  type = string
}

variable ecs_task_cqf_arn {}

variable subnets {
  type = list(string)
}

variable security_groups {
  type = list(string)
}

variable container_port {
  type = number
}

variable target_group {}

variable service_connect {
  type = bool
}