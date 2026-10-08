variable "name" {
  description = "Nombre base de la sucursal."
  type        = string
}

variable "project_id" {
  description = "ID del proyecto GCP (ejemplo academico)."
  type        = string
  default     = "academic-demo-project"
}

variable "enabled" {
  description = "Si el monitoreo esta habilitado para la sucursal."
  type        = bool
  default     = true
}

variable "retention_days" {
  description = <<-EOT
    Dias de retencion deseados para los logs de la sucursal. Se documenta como
    metadato porque Cloud Logging gestiona la retencion mediante "log buckets"
    a nivel de proyecto (google_logging_project_bucket_config), fuera del
    alcance de este modulo por sucursal.
  EOT
  type        = number
  default     = 14
}

variable "notification_channels" {
  description = "Lista de IDs de canales de notificacion existentes (opcional)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Etiquetas comunes."
  type        = map(string)
  default     = {}
}
