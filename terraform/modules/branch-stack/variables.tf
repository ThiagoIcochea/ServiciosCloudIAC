variable "environment" {
  description = "Entorno a provisionar (development | staging | production). Filtra config/branches/branches.yaml."
  type        = string

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "environment debe ser development, staging o production."
  }
}

variable "gcp_project_id" {
  description = "ID del proyecto GCP (ejemplo academico, no se despliega realmente sin credenciales)."
  type        = string
  default     = "academic-demo-project"
}

variable "branches_file" {
  description = "Ruta al archivo YAML con la definicion de sucursales. Por defecto, config/branches/branches.yaml en la raiz del repositorio."
  type        = string
  default     = ""
}
