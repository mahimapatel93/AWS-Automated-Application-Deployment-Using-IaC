output "rds_db_endpoint" {
  value = aws_db_instance.rds_db.endpoint
}

output "rds_db_password" {
  value = sensitive(data.aws_ssm_parameter.rds_db_password.value)
}