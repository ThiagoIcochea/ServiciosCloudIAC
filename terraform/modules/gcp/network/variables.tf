variable "name" {
  description = "Nombre base de la sucursal."
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "El nombre de la sucursal no puede estar vacio."
  }
}

variable "project_id" {
  description = "ID del proyecto GCP. Valor de ejemplo academico: no se despliega realmente (sin credenciales GCP)."
  type        = string
  default     = "academic-demo-project"
}

variable "region" {
  description = "Region GCP donde se crea la subnet de la sucursal."
  type        = string
}

variable "subnet_cidr" {
  description = "Bloque CIDR de la subnet de la sucursal."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr debe ser un bloque CIDR IPv4 valido, por ejemplo 10.20.1.0/26."
  }
}

variable "tags" {
  description = "Etiquetas comunes (se traducen a 'labels' en GCP, en minusculas)."
  type        = map(string)
  default     = {}
}
