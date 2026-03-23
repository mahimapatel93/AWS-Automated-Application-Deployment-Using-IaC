variable "env_name" {
  type = string
  description = "Environment to deploy."
}

variable "private_subnet_ids" {
  type = list(string)
  description = "Private subnet ids."
}

variable "vpc_id" {
  type = string
  description = "VPC Id"
}

variable "rds_sg_ingress_rules" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {}
}

variable "vpc_cidr" {
  type = string
  description = "VPC Cird"
}

variable "rds_db_username" {
  type        = string
  description = "RDS Username"
}

variable "rds_db_parameter_name" {
  type = string
  description = "RDS Parameter name for password."
}