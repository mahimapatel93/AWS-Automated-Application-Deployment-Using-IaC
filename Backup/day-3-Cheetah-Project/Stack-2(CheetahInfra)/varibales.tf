########################
# Networking
########################
variable "vpc_cidr" {
  type        = string
  description = "Vpc cidr."
}

variable "env_name" {
  type        = string
  description = "Environment name."
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets."
}

variable "private_subnet_count" {
  type = number
  description = "Number of private subnets."
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

variable "rds_db_username" {
  type        = string
  description = "RDS DB Username."
}

variable "rds_db_parameter_name" {
  type        = string
  description = "RDS Parameter name for password."
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "jar_file_name" {
  type        = string
  description = "Jar file name"
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

variable "slack_web_hook_url" {
  type        = string
  description = "Slack webhook url."
}

variable "fe_instance_type" {
  type = string
  description = "FE instance type"
}

variable "origin_id" {
  type    = string
}

variable "default_behavior_allowed_methods" {
  type    = list(string)
}

variable "default_behavior_cached_methods" {
  type    = list(string)
}

variable "default_behavior_forwarded_values_header" {
  type    = list(string)
}