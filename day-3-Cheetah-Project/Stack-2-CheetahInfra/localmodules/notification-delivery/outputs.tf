output "lambda_function_arn" {
  value = aws_lambda_function.cloudwatch_sns_to_slack_notification.arn
}