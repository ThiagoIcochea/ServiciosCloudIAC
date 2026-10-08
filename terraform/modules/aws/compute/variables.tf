variable "name" {
  description = "Nombre base de la sucursal."
  type        = string
}

variable "subnet_id" {
  description = "ID de la subnet donde se lanzan los servidores."
  type        = string
}

variable "security_group_ids" {
  description = "Lista de Security Group IDs a asociar a los servidores."
  type        = list(string)
  default     = []
}

variable "ami_id" {
  description = <<-EOT
    AMI a utilizar para los servidores. Este proyecto NO cuenta con credenciales
    de AWS, por lo que no se resuelve dinamicamente via data source: se declara
    como variable explicita (ejemplo academico, no valida para despliegue real
    sin verificar la AMI vigente en la region destino).
  EOT
  type        = string
  default     = "ami-0c101f26f147fa7fd" # Ejemplo academico (Amazon Linux 2023, us-east-1)
}

# Interfaz comun entre proveedores: "size" en lugar de un tipo de instancia
# especifico de AWS. El modulo traduce size -> instance_type.
variable "size_to_instance_type" {
  description = "Mapa que traduce el tamano logico comun (small/medium/large) a un instance_type de AWS."
  type        = map(string)
  default = {
    small  = "t3.micro"
    medium = "t3.small"
    large  = "t3.medium"
  }
}

variable "servers" {
  description = "Lista de servidores logicos de la sucursal (interfaz comun con GCP)."
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
  description = "Etiquetas comunes aplicadas a los servidores."
  type        = map(string)
  default     = {}
}
