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

variable "resource_owner" {
    type = string
    description = <<EOF
        The name of the person creating the AWS resource.
        This is used only in Tags on AWS resources, hopefully as a way to give a point of contact.
        You may set this in a tfvars file or via TF_VAR_resource_owner environment variable.
        Else the default value will be taken.
    EOF
    default = "Not Specified via Terraform"
}