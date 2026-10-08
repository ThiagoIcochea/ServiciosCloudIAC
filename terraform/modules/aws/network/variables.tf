variable "name" {
  description = "Nombre base de la sucursal (usado como prefijo de los recursos de red)."
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "El nombre de la sucursal no puede estar vacio."
  }
}

variable "cidr_block" {
  description = "Bloque CIDR de la VPC de la sucursal."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block debe ser un bloque CIDR IPv4 valido, por ejemplo 10.10.1.0/24."
  }
}

variable "subnet_cidr" {
  description = "Bloque CIDR de la subnet publica dentro de la VPC de la sucursal."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr debe ser un bloque CIDR IPv4 valido, por ejemplo 10.10.1.0/26."
  }
}

variable "availability_zone" {
  description = "Zona de disponibilidad para la subnet. Si se deja vacio, AWS selecciona una automaticamente en el plan real."
  type        = string
  default     = null
}

variable "tags" {
  description = "Etiquetas comunes aplicadas a todos los recursos de red de la sucursal."
  type        = map(string)
  default     = {}
}
