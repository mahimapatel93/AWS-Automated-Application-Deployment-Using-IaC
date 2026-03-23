resource "aws_sns_topic" "error_alert_topic" {
  name = "cheetah-${var.env_name}-alert-topic"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.error_alert_topic.arn
  protocol  = "lambda"
  endpoint  = var.lambda_function_arn
}