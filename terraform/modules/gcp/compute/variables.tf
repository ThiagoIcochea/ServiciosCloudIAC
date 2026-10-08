variable "name" {
  description = "Nombre base de la sucursal."
  type        = string
}

variable "project_id" {
  description = "ID del proyecto GCP (ejemplo academico)."
  type        = string
  default     = "academic-demo-project"
}

variable "zone" {
  description = "Zona GCP donde se crean las instancias."
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self link de la subnetwork de la sucursal."
  type        = string
}

variable "image" {
  description = "Imagen de arranque para las instancias (ejemplo academico)."
  type        = string
  default     = "debian-cloud/debian-12"
}

# Interfaz comun entre proveedores: "size" en lugar de un machine_type
# especifico de GCP. El modulo traduce size -> machine_type.
variable "size_to_machine_type" {
  description = "Mapa que traduce el tamano logico comun (small/medium/large) a un machine_type de GCP."
  type        = map(string)
  default = {
    small  = "e2-micro"
    medium = "e2-small"
    large  = "e2-medium"
  }
}

variable "servers" {
  description = "Lista de servidores logicos de la sucursal (interfaz comun con AWS)."
  type = list(object({
    name = string
    role = string
    size = string
  }))

  validation {
    condition     = length(var.servers) >= 1
    error_message = "Cada sucursal debe definir al menos un servidor."
  }

  validation {
    condition     = alltrue([for s in var.servers : contains(["small", "medium", "large"], s.size)])
    error_message = "El campo 'size' de cada servidor debe ser small, medium o large."
  }
}

variable "tags" {
  description = "Etiquetas comunes (se traducen a 'labels' en GCP)."
  type        = map(string)
  default     = {}
}
