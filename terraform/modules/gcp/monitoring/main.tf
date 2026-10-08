# Modulo: monitoreo por sucursal (GCP)
# Crea una politica de alerta de Cloud Monitoring por alto uso de CPU en las
# instancias de la sucursal (RF-04), equivalente funcional de la alarma de
# CloudWatch del modulo aws/monitoring.

locals {
  # GCP user_labels: solo minusculas, numeros, guiones y guion bajo (misma
  # restriccion que modules/gcp/compute).
  safe_labels = { for k, v in var.tags : lower(k) => lower(replace(v, "/[^a-zA-Z0-9_-]/", "-")) }
}

resource "google_monitoring_alert_policy" "cpu_high" {
  count = var.enabled ? 1 : 0

  project      = var.project_id
  display_name = "${var.name}-cpu-high"
  combiner     = "OR"

  conditions {
    display_name = "CPU > 80% en ${var.name}"

    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\" AND resource.labels.instance_id = starts_with(\"${var.name}\")"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "300s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = var.notification_channels

  user_labels = merge(local.safe_labels, {
    retention_days_hint = tostring(var.retention_days)
  })
}
