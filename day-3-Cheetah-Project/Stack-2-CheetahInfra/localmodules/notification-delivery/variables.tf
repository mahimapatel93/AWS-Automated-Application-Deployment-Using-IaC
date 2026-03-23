variable "env_name" {
  type        = string
  description = "Environment name"
}

variable "slack_web_hook_url" {
  type        = string
  description = "Slack webhook url."
}

variable "alert_sns_topic_arn" {
  type        = string
  description = "SNS topic arn."
}