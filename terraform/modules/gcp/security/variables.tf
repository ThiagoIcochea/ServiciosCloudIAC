variable "name" {
  description = "Nombre base de la sucursal."
  type        = string
}

variable "project_id" {
  description = "ID del proyecto GCP (ejemplo academico)."
  type        = string
  default     = "academic-demo-project"
}

variable "network_id" {
  description = "ID de la VPC Network donde se crean las reglas de firewall."
  type        = string
}

# Interfaz comun con el modulo aws/security.
variable "rules" {
  description = "Lista de reglas de seguridad logicas de la sucursal."
  type = list(object({
    name      = string
    port      = number
    protocol  = string
    cidr      = string
    direction = string # "ingress" | "egress"
  }))

  validation {
    condition     = length(var.rules) >= 1
    error_message = "Cada sucursal debe definir al menos una regla de seguridad."
  }

  validation {
    condition     = alltrue([for r in var.rules : contains(["ingress", "egress"], r.direction)])
    error_message = "direction debe ser 'ingress' o 'egress'."
  }

  validation {
    condition     = alltrue([for r in var.rules : r.port > 0 && r.port <= 65535])
    error_message = "port debe estar entre 1 y 65535."
  }
}

variable "tags" {
  description = "Etiquetas comunes (se traducen a 'target_tags' en GCP)."
  type        = map(string)
  default     = {}
}
