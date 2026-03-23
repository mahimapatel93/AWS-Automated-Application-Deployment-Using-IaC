data "archive_file" "zip_cloudwatch_sns_to_slack_lambda_function" {
  type = "zip"
  source_file = "${path.module}/include/cloudwatch-sns-slack-notification.py"
  output_path = "${path.module}/include/cloudwatch-sns-slack-notification.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

data "aws_iam_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
}

resource "aws_lambda_function" "cloudwatch_sns_to_slack_notification" {
  function_name = "cheetah-${var.env_name}-alert-func"
  role          = aws_iam_role.lambda_exec_role.arn
  architectures = ["x86_64"]
  description   = "An Amazon SNS trigger that sends CloudWatch alarm notifications to Slack."
  filename      = data.archive_file.zip_cloudwatch_sns_to_slack_lambda_function.output_path
  source_code_hash = data.archive_file.zip_cloudwatch_sns_to_slack_lambda_function.output_base64sha256
  handler       = "cloudwatch-sns-slack-notification.lambda_handler"
  package_type  = "Zip"
  memory_size   = 128
  runtime       = "python3.12"

  environment {
    variables = {
      slackHookUrl = var.slack_web_hook_url
    }
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_sns_to_slack_notification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.alert_sns_topic_arn
}