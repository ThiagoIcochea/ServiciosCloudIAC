# Modulo compuesto: provisiona TODAS las sucursales de un entorno dado,
# para ambos proveedores (AWS y GCP), reutilizando los 8 modulos base
# (network/compute/security/monitoring x 2 proveedores).
#
# Este es el unico lugar donde se "orquesta" el patron comun de 50
# sucursales: agregar una sucursal nueva es agregar una entrada en
# config/branches/branches.yaml, NO escribir nuevo codigo Terraform (RNF
# de extensibilidad, seccion 7 del enunciado).

locals {
  default_branches_file = "${path.module}/../../../config/branches/branches.yaml"
  branches_file         = var.branches_file != "" ? var.branches_file : local.default_branches_file

  all_branches = yamldecode(file(local.branches_file)).sucursales

  # Mapa id -> sucursal, filtrado por entorno.
  branches = { for b in local.all_branches : b.id => b if b.environment == var.environment }

  aws_branches = { for id, b in local.branches : id => b if b.provider == "aws" }
  gcp_branches = { for id, b in local.branches : id => b if b.provider == "gcp" }
}

# ---------------------------------------------------------------------------
# AWS
# ---------------------------------------------------------------------------

module "aws_network" {
  source = "../aws/network"

  for_each = local.aws_branches

  name        = each.value.id
  cidr_block  = each.value.network.cidr_block
  subnet_cidr = each.value.network.subnet_cidr
  tags        = each.value.tags
}

module "aws_security" {
  source = "../aws/security"

  for_each = local.aws_branches

  name   = each.value.id
  vpc_id = module.aws_network[each.key].vpc_id
  rules  = each.value.security_rules
  tags   = each.value.tags
}

module "aws_compute" {
  source = "../aws/compute"

  for_each = local.aws_branches

  name               = each.value.id
  subnet_id          = module.aws_network[each.key].subnet_id
  security_group_ids = [module.aws_security[each.key].security_group_id]
  servers            = each.value.servers
  tags               = each.value.tags
}

module "aws_monitoring" {
  source = "../aws/monitoring"

  for_each = local.aws_branches

  name           = each.value.id
  enabled        = each.value.monitoring.enabled
  retention_days = each.value.monitoring.retention_days
  instance_ids   = module.aws_compute[each.key].instance_ids
  tags           = each.value.tags
}

# ---------------------------------------------------------------------------
# GCP
# ---------------------------------------------------------------------------

module "gcp_network" {
  source = "../gcp/network"

  for_each = local.gcp_branches

  name        = each.value.id
  project_id  = var.gcp_project_id
  region      = each.value.region
  subnet_cidr = each.value.network.subnet_cidr
  tags        = each.value.tags
}

module "gcp_security" {
  source = "../gcp/security"

  for_each = local.gcp_branches

  name       = each.value.id
  project_id = var.gcp_project_id
  network_id = module.gcp_network[each.key].network_id
  rules      = each.value.security_rules
  tags       = each.value.tags
}

module "gcp_compute" {
  source = "../gcp/compute"

  for_each = local.gcp_branches

  name                 = each.value.id
  project_id           = var.gcp_project_id
  zone                 = "${each.value.region}-a"
  subnetwork_self_link = module.gcp_network[each.key].subnetwork_self_link
  servers              = each.value.servers
  tags                 = each.value.tags
}

module "gcp_monitoring" {
  source = "../gcp/monitoring"

  for_each = local.gcp_branches

  name           = each.value.id
  project_id     = var.gcp_project_id
  enabled        = each.value.monitoring.enabled
  retention_days = each.value.monitoring.retention_days
  tags           = each.value.tags
}
