# Modulo: seguridad por sucursal (GCP)
# Crea una regla de firewall por cada entrada de "rules" (interfaz comun con
# aws/security). GCP no tiene "Security Group" como objeto contenedor: cada
# regla es un recurso independiente asociado a la VPC Network (RF-03).

locals {
  rules_by_name    = { for r in var.rules : r.name => r }
  tags_description = join(", ", [for k, v in var.tags : "${k}=${v}"])
}

resource "google_compute_firewall" "this" {
  for_each = local.rules_by_name

  name        = "${var.name}-${each.value.name}"
  project     = var.project_id
  network     = var.network_id
  direction   = upper(each.value.direction)
  description = local.tags_description != "" ? "${each.value.name} (${local.tags_description})" : each.value.name

  source_ranges      = each.value.direction == "ingress" ? [each.value.cidr] : null
  destination_ranges = each.value.direction == "egress" ? [each.value.cidr] : null

  allow {
    protocol = each.value.protocol
    ports    = [tostring(each.value.port)]
  }

  target_tags = [var.name]
}
