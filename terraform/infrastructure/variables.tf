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
    description = <<EOF
        A list of subnets that resources will use in AWS.
        Specifying manually as these were created prior to Terraform introduction into the project.
    EOF
}

variable "esri_ec2_instance_id" {
    type = string
    description = <<EOF
        The ID of the EC2 instance that will be used to run the ArcGIS Server.
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

variable "api_loadbalancer_arn" {
    type = string
    description = <<EOF
        The identifier for the API Load Balancer.  This is the load balancer that hosts the
        API, and various other non-UI servers.  Such as CQF, Data Store, etc...
        Specifying manually as this was created prior to Terraform introduction into the project.
    EOF
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