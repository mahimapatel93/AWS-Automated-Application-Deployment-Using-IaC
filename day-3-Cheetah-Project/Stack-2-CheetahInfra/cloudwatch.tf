module "cloudwatch" {
  source = "./localmodules/monitoring"

  env_name      = var.env_name
  sns_topic_arn = module.sns.sns_topic_arn
}