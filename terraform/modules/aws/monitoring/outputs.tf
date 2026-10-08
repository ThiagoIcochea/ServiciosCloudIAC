output "log_group_name" {
  description = "Nombre del Log Group de CloudWatch creado para la sucursal."
  value       = var.enabled ? aws_cloudwatch_log_group.this[0].name : null
}

output "alarm_names" {
  description = "Mapa servidor -> nombre de la alarma de CPU asociada."
  value       = { for k, v in aws_cloudwatch_metric_alarm.cpu : k => v.alarm_name }
}
