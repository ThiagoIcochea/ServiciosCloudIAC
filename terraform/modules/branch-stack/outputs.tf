output "branch_ids" {
  description = "Identificadores de todas las sucursales del entorno (AWS + GCP)."
  value       = keys(local.branches)
}

output "aws_branch_ids" {
  description = "Identificadores de las sucursales AWS del entorno."
  value       = keys(local.aws_branches)
}

output "gcp_branch_ids" {
  description = "Identificadores de las sucursales GCP del entorno."
  value       = keys(local.gcp_branches)
}

output "branch_count" {
  description = "Numero total de sucursales provisionadas en el entorno."
  value       = length(local.branches)
}

output "aws_vpc_ids" {
  description = "Mapa sucursal -> VPC ID (AWS)."
  value       = { for k, m in module.aws_network : k => m.vpc_id }
}

output "gcp_network_ids" {
  description = "Mapa sucursal -> Network ID (GCP)."
  value       = { for k, m in module.gcp_network : k => m.network_id }
}
