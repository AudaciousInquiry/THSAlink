variable "security_groups" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "file_system" {
  type = any
}