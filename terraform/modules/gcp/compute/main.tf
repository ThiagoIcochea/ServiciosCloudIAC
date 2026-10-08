# Modulo: computo por sucursal (GCP)
# Crea los servidores (Compute Engine) de una sucursal a partir de la misma
# interfaz generica "servers" usada en aws/compute (RF-02).

locals {
  servers_by_name = { for s in var.servers : s.name => s }
  # GCP labels: solo minusculas, numeros y guiones.
  safe_labels = { for k, v in var.tags : lower(k) => lower(replace(v, "/[^a-zA-Z0-9-]/", "-")) }
}

resource "google_compute_instance" "this" {
  for_each = local.servers_by_name

  name         = "${var.name}-${each.value.name}"
  project      = var.project_id
  zone         = var.zone
  machine_type = var.size_to_machine_type[each.value.size]

  labels = merge(local.safe_labels, {
    role = each.value.role
  })

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = var.subnetwork_self_link
    access_config {} # IP publica efimera, equivalente a map_public_ip_on_launch de AWS
  }
}
