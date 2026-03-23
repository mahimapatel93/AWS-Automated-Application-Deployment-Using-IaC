locals {
  db_password = sensitive(data.aws_ssm_parameter.rds_db_password.value)
}

resource "aws_db_subnet_group" "private_sub_grp" {
  name       = "cheetah-${var.env_name}-subnet-grp"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "cheetah-${var.env_name}-subnet-grp"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "cheetah-${var.env_name}-rds-sg"
  description = "Security group for RDS database."
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_be_ipv4" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_db_instance" "rds_db" {
  identifier          = "cheetah-${var.env_name}-db-instance"
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = var.rds_db_username
  password            = local.db_password
  db_subnet_group_name    = aws_db_subnet_group.private_sub_grp.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false
  storage_encrypted       = true
  kms_key_id              = data.aws_kms_key.aws_managed_rds_key.arn

  tags = {
    Name = "cheetah-${var.env_name}-db-instance"
  }
}