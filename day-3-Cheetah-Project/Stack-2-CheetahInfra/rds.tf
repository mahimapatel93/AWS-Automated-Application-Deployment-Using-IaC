module "rds" {
  source = "./localmodules/storage"
  env_name           = var.env_name
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr
  rds_sg_ingress_rules = var.rds_sg_ingress_rules
  rds_db_username       = var.rds_db_username
  rds_db_parameter_name = var.rds_db_parameter_name
}