# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "ECS CPU Utilisation"
          view    = "timeSeries"
          stacked = false
          metrics = [[
            "AWS/ECS",
            "CPUUtilization",
            "ClusterName", "${var.app_name}-cluster",
            "ServiceName", "${var.app_name}-service"
          ]]
          period = 60
          stat   = "Average"
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "ECS Memory Utilisation"
          view    = "timeSeries"
          stacked = false
          metrics = [[
            "AWS/ECS",
            "MemoryUtilization",
            "ClusterName", "${var.app_name}-cluster",
            "ServiceName", "${var.app_name}-service"
          ]]
          period = 60
          stat   = "Average"
          region = var.aws_region
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          title   = "Container Logs"
          view    = "table"
          query   = "SOURCE '/ecs/${var.app_name}' | fields @timestamp, @message | sort @timestamp desc | limit 50"
          region  = var.aws_region
        }
      }
    ]
  })
}

# Alarm: CPU too high
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.app_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU above 80% for 2 minutes"

  dimensions = {
    ClusterName = "${var.app_name}-cluster"
    ServiceName = "${var.app_name}-service"
  }

  tags = { Project = var.app_name }
}

# Alarm: Service has no running tasks
resource "aws_cloudwatch_metric_alarm" "no_running_tasks" {
  alarm_name          = "${var.app_name}-no-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "No running tasks — service may be down"

  dimensions = {
    ClusterName = "${var.app_name}-cluster"
    ServiceName = "${var.app_name}-service"
  }

  tags = { Project = var.app_name }
}