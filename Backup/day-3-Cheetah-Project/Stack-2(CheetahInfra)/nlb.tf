module "nlb" {
  source = "./localmodules/loadbalancing"
  env_name   = var.env_name
  vpc_id     = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_cidr   = module.vpc.vpc_cidr
  public_subnet_ids = module.vpc.public_subnet_ids
}