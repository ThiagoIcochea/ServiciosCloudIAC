# Pruebas del modulo gcp/compute usando mock_provider.
# CP03 - Validacion de modulos GCP. CP05 - Dos servidores por sucursal.

mock_provider "google" {}

variables {
  name                  = "suc-002"
  zone                  = "southamerica-east1-a"
  subnetwork_self_link  = "https://mock/subnetworks/suc-002-subnet"
  servers = [
    { name = "web-002", role = "web", size = "small" },
    { name = "app-002", role = "app", size = "small" },
  ]
  tags = { sucursal_id = "suc-002" }
}

run "crea_dos_servidores_con_el_machine_type_correcto" {
  command = plan

  module {
    source = "../modules/gcp/compute"
  }

  assert {
    condition     = length(google_compute_instance.this) == 2
    error_message = "Se esperaban exactamente 2 servidores (RF-02)."
  }

  assert {
    condition     = google_compute_instance.this["web-002"].machine_type == "e2-micro"
    error_message = "El size 'small' deberia traducirse a e2-micro."
  }
}

run "rechaza_lista_de_servidores_vacia" {
  command = plan

  module {
    source = "../modules/gcp/compute"
  }

  variables {
    servers = []
  }

  expect_failures = [
    var.servers,
  ]
}
