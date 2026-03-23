module "vpc" {
  source = "./localmodules/networking"

  env_name = var.env_name
  vpc_cidr = var.vpc_cidr
  public_subnet_count = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
}