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

variable image_repository {
  type = string
}

variable image_name {
  type = string
}

variable image_tag {
  type = string
}

variable ecs_task_role {}

variable container_environment {
  type = string
}

variable container_environment_file {
  type = string
}

variable healthcheck {
  type = string
}

variable cpu_size {
  type = string
}

variable memory_size {
  type = string
}

variable container_port {
  type = number
}

variable mount_points {
  type = string
}

variable volume_filesystem_id {
  type = string
}

variable volume_root_directory {
  type = string
}

variable volume_name {
  type = string
}