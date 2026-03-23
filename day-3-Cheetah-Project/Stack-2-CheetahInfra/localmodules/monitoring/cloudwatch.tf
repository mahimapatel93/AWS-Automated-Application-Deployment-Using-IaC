resource "time_sleep" "wait_time" {
  create_duration = "300s"
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  depends_on     = [time_sleep.wait_time]
  name           = "cheetah-${var.env_name}-error-count-filter"
  log_group_name = "/datastore/app"

  pattern = "ERROR"

  metric_transformation {
    name      = "AppErrorCount"
    namespace = "AppLogMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "cheetah-${var.env_name}-error-count-alarm"
  alarm_description   = "Triggered when error keyword appears in logs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 30
  threshold           = 1

  metric_name = aws_cloudwatch_log_metric_filter.error_filter.metric_transformation[0].name
  namespace   = aws_cloudwatch_log_metric_filter.error_filter.metric_transformation[0].namespace
  statistic   = "Sum"

  alarm_actions = [
    var.sns_topic_arn
  ]
}