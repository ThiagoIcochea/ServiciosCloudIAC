output "firewall_rule_ids" {
  description = "Mapa nombre de regla -> ID de la regla de firewall creada."
  value       = { for k, v in google_compute_firewall.this : k => v.id }
}
