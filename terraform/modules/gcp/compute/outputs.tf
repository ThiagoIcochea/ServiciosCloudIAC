output "instance_ids" {
  description = "Mapa nombre de servidor -> ID de instancia de Compute Engine."
  value       = { for k, v in google_compute_instance.this : k => v.instance_id }
}

output "self_links" {
  description = "Mapa nombre de servidor -> self link de la instancia."
  value       = { for k, v in google_compute_instance.this : k => v.self_link }
}
