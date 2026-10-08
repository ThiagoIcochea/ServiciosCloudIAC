# Este directorio no define infraestructura propia: solo aloja los archivos
# .tftest.hcl (CP01, CP02, CP03, CP04, CP05, CP07, CP08, CP09). Cada bloque
# "run" en los archivos de prueba apunta explicitamente, via "module { source
# = ... }", al modulo real que se quiere validar. Este archivo solo declara
# los providers para que `terraform init` pueda resolverlos.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
