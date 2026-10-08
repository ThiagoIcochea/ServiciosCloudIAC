# Pruebas del modulo aws/network usando mock_provider (sin credenciales AWS).
# CP02 - Validacion de modulos AWS.

mock_provider "aws" {}

variables {
  name        = "suc-001"
  cidr_block  = "10.10.1.0/24"
  subnet_cidr = "10.10.1.0/26"
  tags = {
    sucursal_id = "suc-001"
    entorno     = "production"
  }
}

run "vpc_usa_el_cidr_declarado" {
  command = plan

  module {
    source = "../modules/aws/network"
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.10.1.0/24"
    error_message = "El CIDR de la VPC no coincide con el valor configurado."
  }
}

run "subnet_usa_el_cidr_declarado" {
  command = plan

  module {
    source = "../modules/aws/network"
  }

  assert {
    condition     = aws_subnet.this.cidr_block == "10.10.1.0/26"
    error_message = "El CIDR de la subnet no coincide con el valor configurado."
  }

  assert {
    condition     = aws_subnet.this.map_public_ip_on_launch == true
    error_message = "La subnet deberia asignar IP publica en esta demo."
  }
}

run "ruta_por_defecto_apunta_al_internet_gateway" {
  command = plan

  module {
    source = "../modules/aws/network"
  }

  assert {
    condition     = anytrue([for r in aws_route_table.this.route : r.cidr_block == "0.0.0.0/0"])
    error_message = "La tabla de rutas deberia tener una ruta por defecto 0.0.0.0/0."
  }
}

run "rechaza_cidr_invalido" {
  command = plan

  module {
    source = "../modules/aws/network"
  }

  variables {
    name        = "suc-invalida"
    cidr_block  = "no-es-un-cidr"
    subnet_cidr = "10.10.1.0/26"
    tags        = {}
  }

  expect_failures = [
    var.cidr_block,
  ]
}
