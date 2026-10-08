# Modulo: red por sucursal (GCP)
# Crea una VPC Network en modo personalizado y una Subnetwork regional por
# sucursal, equivalente funcional del modulo aws/network (RF-01).
#
# google_compute_network y google_compute_subnetwork no admiten "labels"
# (a diferencia de aws_vpc/aws_subnet con sus "tags"): es una diferencia
# tecnica real entre proveedores, documentada en el README del modulo. Para
# mantener la interfaz comun (todos los modulos reciben "tags") sin crear un
# argumento sin uso, las etiquetas se vuelcan en "description".

locals {
  tags_description = join(", ", [for k, v in var.tags : "${k}=${v}"])
}

resource "google_compute_network" "this" {
  name                    = "${var.name}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = local.tags_description
}

resource "google_compute_subnetwork" "this" {
  name          = "${var.name}-subnet"
  project       = var.project_id
  network       = google_compute_network.this.id
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  description   = local.tags_description
}

resource "google_compute_router" "this" {
  name    = "${var.name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
