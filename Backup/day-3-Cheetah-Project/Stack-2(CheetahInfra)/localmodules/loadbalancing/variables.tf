variable "env_name" {
  type        = string
  description = "Environment to deploy"
}

variable "vpc_id" {
  type = string
  description = "VPC id"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet id's"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet id's"
}