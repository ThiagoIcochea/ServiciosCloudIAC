# Pruebas del modulo gcp/monitoring usando mock_provider.
# CP03 - Validacion de modulos GCP. CP08 - Configuracion de monitoreo.

mock_provider "google" {}

variables {
  name    = "suc-002"
  enabled = true
}

run "crea_politica_de_alerta_cuando_monitoreo_habilitado" {
  command = plan

  module {
    source = "../modules/gcp/monitoring"
  }

  assert {
    condition     = google_monitoring_alert_policy.cpu_high[0].display_name == "suc-002-cpu-high"
    error_message = "La politica de alerta deberia nombrarse <sucursal>-cpu-high."
  }

  assert {
    condition     = google_monitoring_alert_policy.cpu_high[0].combiner == "OR"
    error_message = "El combiner deberia ser OR."
  }
}

run "no_crea_recursos_cuando_monitoreo_deshabilitado" {
  command = plan

  module {
    source = "../modules/gcp/monitoring"
  }

  variables {
    enabled = false
  }

  assert {
    condition     = length(google_monitoring_alert_policy.cpu_high) == 0
    error_message = "No deberia crearse politica de alerta si enabled=false."
  }
}
