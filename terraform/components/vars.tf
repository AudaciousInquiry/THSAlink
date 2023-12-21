variable "environment" {
  description = "The target environment for the deployment.  Intended to be dev, test, or prod"
  type = string
}

variable "customer" {
  description = "This is a code that denotes the customer of this deployment.  For example: thsa"
  type = string
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
  type = object(
    {
    primary = list(string)
    secondary = list(string)
    }
  )
  description = <<EOF
    Subnets that resources in AWS will use.  This is setup as a map so you can have different "categories"
    so to speak of subnets.  Intented to be primary and secondary.  This is a result of how THSALink was
    originally configured pre-Terraform and can probably be made cleaner in a fresh project.
    Existing subnet IDs manually specified as they were created prior to Terraform introduction into the project.
  EOF
}

variable "security_groups" {
  type = list(string)
  description = <<EOF
        A list of AWS Security Groups that resources will use in AWS.
        Specifying manually as these were created prior to Terraform introduction into the project.
    EOF
}

variable "vpc_id" {
  type = string
  description = <<EOF
        The identifier of the VPC that AWS resources will be stood up in.
        Right now this project is setup for everything to be in one VPC.
        Specifying manually as these were created prior to Terraform introduction into the project.
    EOF
}

variable "loadbalancer_arn" {
  type = string
}

# DEFAULT CONTAINER STUFF
variable "default_cpu_size" {
  type = string
}

variable "default_memory_size" {
  type = string
}

variable "default_docker_tag" {
  type = string
}

# DATA STORE SPECIFIC
variable "datastore_docker_tag" {
  type = string
}

variable "datastore_cpu_size" {
  type = string
}

variable "datastore_memory_size" {
  type = string
}

variable "datastore_container_port" {
  type = number
}

variable "datastore_external_listener_port" {
  type = string
}

variable "datastore_docker_image_name" {
  type = string
}

# CQF SPECIFIC
variable "cqf_docker_tag" {
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

variable "cqf_docker_image_name" {
  type = string
}

# CONSUMER SPECIFIC
variable "consumer_docker_tag" {
  type = string
}

variable "consumer_cpu_size" {
  type = string
}

variable "consumer_memory_size" {
  type = string
}

variable "consumer_container_port" {
  type = number
}

variable "consumer_external_listener_port" {
  type = string
}

variable "consumer_docker_image_name" {
  type = string
}

# API SPECIFIC
variable "api_docker_tag" {
  type = string
}

variable "api_cpu_size" {
  type = string
}

variable "api_memory_size" {
  type = string
}

variable "api_container_port" {
  type = number
}

variable "api_external_listener_port" {
  type = string
}

variable "api_docker_image_name" {
  type = string
}

# WEB SPECIFIC
variable "web_docker_tag" {
  type = string
}

variable "web_cpu_size" {
  type = string
}

variable "web_memory_size" {
  type = string
}

variable "web_container_port" {
  type = number
}

variable "web_external_listener_port" {
  type = string
}

variable "web_docker_image_name" {
  type = string
}

# KEYCLOAK SPECIFIC
variable "keycloak_docker_tag" {
  type = string
}

variable "keycloak_cpu_size" {
  type = string
}

variable "keycloak_memory_size" {
  type = string
}

variable "keycloak_container_port" {
  type = number
}

variable "keycloak_external_listener_port" {
  type = string
}

variable "keycloak_docker_image_name" {
  type = string
}