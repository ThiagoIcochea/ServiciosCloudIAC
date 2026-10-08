# Modulo: monitoreo por sucursal (AWS)
# Crea un Log Group de CloudWatch y una alarma de CPU por servidor (RF-04).

resource "aws_cloudwatch_log_group" "this" {
  count = var.enabled ? 1 : 0

  name              = "/sucursales/${var.name}"
  retention_in_days = var.retention_days

  tags = merge(var.tags, {
    Name = "${var.name}-log-group"
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  for_each = var.enabled ? var.instance_ids : {}

  alarm_name          = "${var.name}-${each.key}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU > 80% en ${each.key} (${var.name})"

  dimensions = {
    InstanceId = each.value
  }

  tags = var.tags
}
