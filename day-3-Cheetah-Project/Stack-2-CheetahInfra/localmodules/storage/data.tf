data "aws_ssm_parameter" "rds_db_password" {
  name            = var.rds_db_parameter_name
  with_decryption = true
}

data "aws_kms_key" "aws_managed_rds_key" {
  key_id = "alias/aws/rds"
}