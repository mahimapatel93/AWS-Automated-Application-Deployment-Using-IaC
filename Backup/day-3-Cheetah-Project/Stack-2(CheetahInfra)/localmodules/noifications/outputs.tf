output "sns_topic_arn" {
  value = aws_sns_topic.error_alert_topic.arn
}