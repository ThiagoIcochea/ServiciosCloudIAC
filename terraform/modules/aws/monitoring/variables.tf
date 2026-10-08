variable "name" {
  description = "Nombre base de la sucursal."
  type        = string
}

variable "enabled" {
  description = "Si el monitoreo esta habilitado para la sucursal."
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Dias de retencion de logs en CloudWatch Logs."
  type        = number
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.retention_days)
    error_message = "retention_days debe ser uno de los valores soportados por CloudWatch Logs."
  }
}

variable "instance_ids" {
  description = "Mapa nombre de servidor -> ID de instancia, para asociar alarmas de CPU."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Etiquetas comunes."
  type        = map(string)
  default     = {}
}
