variable "aws_region" {
  description = "The region for components setup by Terraform.  us-east-1 for example."
  type = string
}

variable "aws_profile" {
  description = "The name of the configuration profile on this machine for the AWS Account.  As configured in ~/.aws/"
  type = string
}

variable "environment" {
  description = "Intended to describe level of the environment.  For example: dev, test or prod"
  type = string
}

variable "customer" {
  description = "A code to describe the customer.  First proof of concept, for example, being thsa."
  type = string
}

variable "project_code" {
  type = string
}

variable "docker_image_repository" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "subnets_b" {
  type = list(string)
}

variable "security_groups" {
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