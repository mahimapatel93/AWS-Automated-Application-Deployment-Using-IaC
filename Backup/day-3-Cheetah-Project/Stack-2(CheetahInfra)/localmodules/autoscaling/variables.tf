variable "env_name" {
  type        = string
  description = "Environment to deploy"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "rds_db_endpoint" {
  type        = string
  description = "RDS database endpoint"
}

variable "rds_db_uname" {
  type        = string
  description = "RDS database username"
}

variable "jar_file_name" {
  type        = string
  description = "Name of jar file."
}

variable "rds_db_parameter_name" {
  type        = string
  description = "RDS db password parameter name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC Cidr"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id"
}

variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "desired_capacity" {
  type        = number
  description = "Desired capacity"
}

variable "max_size" {
  type        = number
  description = "Max capacity"
}

variable "min_size" {
  type        = number
  description = "Min capacity"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet id's"
}

variable "nlb_tg_arn" {
  type        = string
  description = "Target group ARN"
}

variable "nlb_dns_endpoint" {
  type        = string
  description = "NLB DNS Endpoint"
}

variable "fe_instance_type" {
  type        = string
  description = "FE instance type"
}

variable "alb_tg_arn" {
  type = string
  description = "ALB target group ARN"
}