variable "efs-filesystem" {}

variable "security_groups_arns" {
  type = list(string)
}

variable "subnets_arns" {
  type = list(string)
}

variable "environment" {
  type = string
}