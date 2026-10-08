# Laboratorio de Terraform State local (FASE IV, seccion 12 del enunciado).
#
# Demuestra, con recursos locales (sin credenciales cloud), el ciclo de vida
# completo del estado de Terraform: init, creacion de recursos, consulta del
# estado, modificacion de configuracion, planificacion, actualizacion
# controlada y eliminacion.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

variable "sucursales_demo" {
  description = "Subconjunto de sucursales representadas en este laboratorio local de estado."
  type        = list(string)
  default     = ["suc-001", "suc-002"]
}

resource "random_id" "deployment" {
  byte_length = 4
}

resource "local_file" "sucursal_state_demo" {
  for_each = toset(var.sucursales_demo)

  filename = "${path.module}/output/${each.value}.json"
  content = jsonencode({
    sucursal_id    = each.value
    deployment_id  = random_id.deployment.hex
    managed_by     = "terraform"
    estado         = "activo"
  })
}

output "deployment_id" {
  value = random_id.deployment.hex
}

output "sucursales_desplegadas" {
  value = keys(local_file.sucursal_state_demo)
}
