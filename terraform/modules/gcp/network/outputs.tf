output "network_id" {
  description = "ID de la VPC Network creada para la sucursal."
  value       = google_compute_network.this.id
}

output "subnetwork_id" {
  description = "ID de la Subnetwork de la sucursal."
  value       = google_compute_subnetwork.this.id
}

output "subnetwork_self_link" {
  description = "Self link de la subnetwork, requerido por el modulo de compute."
  value       = google_compute_subnetwork.this.self_link
}
