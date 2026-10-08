# Laboratorio de Infrastructure Drift (FASE VI, seccion 15 del enunciado).
#
# Usa unicamente el provider "local" (sin credenciales cloud) para demostrar
# el ciclo completo de drift: Terraform crea un recurso -> alguien lo
# modifica manualmente por fuera de Terraform -> `terraform plan` detecta la
# diferencia -> se decide si conservar o revertir -> se reconcilia.
#
# El recurso local_file representa, a efectos didacticos, un archivo de
# configuracion de una sucursal (ej. un parametro de un servidor). El
# mecanismo de deteccion (plan/refresh) es el mismo que usaria Terraform
# contra un recurso real de AWS o GCP; lo que cambia es el proveedor.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

variable "sucursal_id" {
  description = "Identificador de la sucursal simulada para el laboratorio de Drift."
  type        = string
  default     = "suc-001"
}

variable "max_connections" {
  description = "Parametro de configuracion gestionado por Terraform (simula un parametro real de servidor, ej. un limite de conexiones)."
  type        = number
  default     = 100
}

resource "local_file" "server_config" {
  filename = "${path.module}/output/${var.sucursal_id}-server.conf"
  content  = <<-EOT
    # Configuracion gestionada por Terraform - NO EDITAR MANUALMENTE
    sucursal_id=${var.sucursal_id}
    max_connections=${var.max_connections}
    managed_by=terraform
  EOT
}

output "config_path" {
  value = local_file.server_config.filename
}

output "max_connections" {
  value = var.max_connections
}
