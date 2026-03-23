module "lambda" {
  source = "./localmodules/notification-delivery"

  env_name = var.env_name
  slack_web_hook_url  = var.slack_web_hook_url
  alert_sns_topic_arn = module.sns.sns_topic_arn
}