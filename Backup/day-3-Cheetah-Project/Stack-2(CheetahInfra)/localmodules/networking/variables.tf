variable "vpc_cidr" {
  type = string
  description = "Vpc cidr."
}

variable "env_name" {
  type = string
  description = "Environment name."
}

variable "public_subnet_count" {
  type = number
  description = "Number of public subnets."
}

variable "private_subnet_count" {
  type = number
  description = "Number of private subnets."
}