module "servers" {

  source = "./localmodules/ec2"

  instance_type = var.instance_type
  no_of_ec2     = var.no_of_ec2

}