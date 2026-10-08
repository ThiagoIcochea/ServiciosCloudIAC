# Pruebas del modulo gcp/security usando mock_provider.
# CP03 - Validacion de modulos GCP. CP07 - Reglas de seguridad.

mock_provider "google" {}

variables {
  name       = "suc-002"
  network_id = "projects/academic-demo-project/global/networks/suc-002-vpc"
  rules = [
    { name = "allow-http", port = 80, protocol = "tcp", cidr = "0.0.0.0/0", direction = "ingress" },
    { name = "allow-https", port = 443, protocol = "tcp", cidr = "0.0.0.0/0", direction = "ingress" },
  ]
}

run "crea_una_regla_de_firewall_por_cada_entrada" {
  command = plan

  module {
    source = "../modules/gcp/security"
  }

  assert {
    condition     = length(google_compute_firewall.this) == 2
    error_message = "Se esperaban 2 reglas de firewall."
  }

  assert {
    condition     = google_compute_firewall.this["allow-http"].direction == "INGRESS"
    error_message = "La direccion deberia traducirse a mayusculas (INGRESS)."
  }
}

run "rechaza_puerto_fuera_de_rango" {
  command = plan

  module {
    source = "../modules/gcp/security"
  }

  variables {
    rules = [
      { name = "regla-mala", port = 70000, protocol = "tcp", cidr = "0.0.0.0/0", direction = "ingress" },
    ]
  }

  expect_failures = [
    var.rules,
  ]
}
