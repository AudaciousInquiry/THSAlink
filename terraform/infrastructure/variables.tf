# Common

variable "environment" {
    type = string
    description = "The target environment for the deployment.  Intended to be dev, test, or prod"
}

variable "customer" {
    type = string
    description = "This is a code that denotes the customer of this deployment.  For example: thsa"
}

variable "project_code" {
    type = string
    description = "This is a code that denotes the project of this deployment.  For example: link or maybe saner"
}

variable "docker_image_repository" {
    type = string
    description = <<EOF
        Location of the public repository containing Docker images for deployment.
        Currently assumes this is an AWS Public EC and so will look something like: public.ecr.aws/k2c9h9v2
    EOF
}

variable "subnets" {
    type = list(string)
}

variable "legacy_link_ec2_server" {
    type = string
}

variable "legacy_esri_ec2_server" {
    type = string
}

// Needed to create DataSync EFS Location
variable "subnets_arns" {
    type = list(string)
}

variable "security_groups" {
    type = list(string)
}

// Needed to create DataSync EFS Location
variable "security_groups_arns" {
    type = list(string)
}

variable "vpc_id" {
    type = string
}

variable "certificate_arn" {
    type = string
}

variable "loadbalancer_arn" {
    type = string
}

variable "resource_owner" {
    type = string
}

# ****************************************************
# CQF - Task
# ****************************************************
variable "cqf_docker_image_tag" {
    type = string
}

variable "cqf_spring_datasource_driver_class_name" {
    type = string
}

variable "cqf_spring_datasource_max_active" {
    type = string
}

variable "cqf_spring_datasource_password" {
    type = string
}

variable "cqf_spring_datasource_username" {
    type = string
}

variable "cqf_spring_datasource_url" {
    type = string
}

variable "cqf_spring_hibernate_dialect" {
    type = string
}

variable "cqf_spring_hibernate_search_enabled" {
    type = string
}

variable "cqf_cpu_size" {
    type = string
}

variable "cqf_memory_size" {
    type = string
}

variable "cqf_container_port" {
    type = number
}

variable "cqf_external_listener_port" {
    type = string
}