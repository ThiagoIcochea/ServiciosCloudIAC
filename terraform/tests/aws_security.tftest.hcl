# Pruebas del modulo aws/security usando mock_provider.
# CP02 - Validacion de modulos AWS. CP07 - Reglas de seguridad.

mock_provider "aws" {}

variables {
  name   = "suc-001"
  vpc_id = "vpc-mock-0001"
  rules = [
    { name = "allow-http", port = 80, protocol = "tcp", cidr = "0.0.0.0/0", direction = "ingress" },
    { name = "allow-ssh-internal", port = 22, protocol = "tcp", cidr = "10.0.0.0/8", direction = "ingress" },
  ]
}

run "crea_un_security_group_por_sucursal" {
  command = plan

  module {
    source = "../modules/aws/security"
  }

  assert {
    condition     = aws_security_group.this.vpc_id == "vpc-mock-0001"
    error_message = "El Security Group deberia asociarse a la VPC de la sucursal."
  }
}

run "crea_una_regla_por_cada_entrada_declarada" {
  command = plan

  module {
    source = "../modules/aws/security"
  }

  assert {
    condition     = length(aws_security_group_rule.this) == 2
    error_message = "Se esperaban 2 reglas de seguridad."
  }

  assert {
    condition     = aws_security_group_rule.this["allow-http"].from_port == 80
    error_message = "La regla allow-http deberia abrir el puerto 80."
  }
}

run "rechaza_direccion_invalida" {
  command = plan

  module {
    source = "../modules/aws/security"
  }

  variables {
    rules = [
      { name = "regla-mala", port = 80, protocol = "tcp", cidr = "0.0.0.0/0", direction = "both" },
    ]
  }

  expect_failures = [
    var.rules,
  ]
}
