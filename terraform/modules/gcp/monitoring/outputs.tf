output "alert_policy_name" {
  description = "Nombre de la politica de alerta creada para la sucursal."
  value       = var.enabled ? google_monitoring_alert_policy.cpu_high[0].name : null
}
