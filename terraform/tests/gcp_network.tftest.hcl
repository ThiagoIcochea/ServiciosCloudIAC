# Pruebas del modulo gcp/network usando mock_provider (sin credenciales GCP).
# CP03 - Validacion de modulos GCP.

mock_provider "google" {}

variables {
  name        = "suc-002"
  project_id  = "academic-demo-project"
  region      = "southamerica-east1"
  subnet_cidr = "10.20.2.0/26"
  tags = {
    sucursal_id = "suc-002"
  }
}

run "subnet_usa_la_region_y_cidr_declarados" {
  command = plan

  module {
    source = "../modules/gcp/network"
  }

  assert {
    condition     = google_compute_subnetwork.this.region == "southamerica-east1"
    error_message = "La subnetwork deberia crearse en la region declarada."
  }

  assert {
    condition     = google_compute_subnetwork.this.ip_cidr_range == "10.20.2.0/26"
    error_message = "El CIDR de la subnetwork no coincide con el valor configurado."
  }
}

run "vpc_es_de_modo_personalizado" {
  command = plan

  module {
    source = "../modules/gcp/network"
  }

  assert {
    condition     = google_compute_network.this.auto_create_subnetworks == false
    error_message = "La VPC deberia crearse en modo personalizado (subnets explicitas por sucursal)."
  }
}

run "rechaza_subnet_cidr_invalido" {
  command = plan

  module {
    source = "../modules/gcp/network"
  }

  variables {
    subnet_cidr = "no-es-un-cidr"
  }

  expect_failures = [
    var.subnet_cidr,
  ]
}
