module "asg" {
  source = "./localmodules/autoscaling"

  env_name        = var.env_name
  instance_type   = var.instance_type
  rds_db_endpoint = module.rds.rds_db_endpoint
  rds_db_uname    = var.rds_db_username
  jar_file_name   = var.jar_file_name
  rds_db_parameter_name = var.rds_db_parameter_name
  vpc_cidr        = module.vpc.vpc_cidr
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.private_subnet_ids[0]
  desired_capacity = var.desired_capacity
  max_size        = var.max_size
  min_size        = var.min_size
  private_subnet_ids = module.vpc.private_subnet_ids
  nlb_tg_arn      = module.nlb.nlb_tg_arn
  nlb_dns_endpoint = module.nlb.nlb_dns_endpoint
  fe_instance_type = var.fe_instance_type
  alb_tg_arn       = module.nlb.alb_tg_arn
}