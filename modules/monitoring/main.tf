resource "aws_cloudwatch_metric_alarm" "healthy_hosts" {
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Minimum"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 2
  period              = 60
  alarm_name          = "production-platform-healthy-targets"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
  treat_missing_data = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 2
  period              = 60
  alarm_name          = "production-platform-http-5xx"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_dashboard" "platform" {
  dashboard_name = "production-platform-dashboard"

  dashboard_body = jsonencode({

    widgets = [


      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Healthy EC2 Targets"
          region = var.aws_region
          period = 60
          stat   = "Minimum"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "LoadBalancer", var.alb_arn_suffix,
              "TargetGroup", var.target_group_arn_suffix
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 5

        properties = {
          title  = "HTTPCODE 5XX Count"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_5XX_Count",
              "LoadBalancer", var.alb_arn_suffix,
              "TargetGroup", var.target_group_arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 5

        properties = {
          title  = "Http request count"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer", var.alb_arn_suffix,
              "TargetGroup", var.target_group_arn_suffix
            ]
          ]
        }
      }

    ]
  })
}


