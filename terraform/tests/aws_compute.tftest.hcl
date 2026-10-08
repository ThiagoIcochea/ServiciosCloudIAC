# Pruebas del modulo aws/compute usando mock_provider.
# CP02 - Validacion de modulos AWS. CP05 - Dos servidores por sucursal.

mock_provider "aws" {}

variables {
  name      = "suc-001"
  subnet_id = "subnet-mock-0001"
  servers = [
    { name = "web-001", role = "web", size = "small" },
    { name = "app-001", role = "app", size = "small" },
  ]
  tags = { sucursal_id = "suc-001" }
}

run "crea_dos_servidores_con_el_tipo_de_instancia_correcto" {
  command = plan

  module {
    source = "../modules/aws/compute"
  }

  assert {
    condition     = length(aws_instance.this) == 2
    error_message = "Se esperaban exactamente 2 servidores (RF-02)."
  }

  assert {
    condition     = aws_instance.this["web-001"].instance_type == "t3.micro"
    error_message = "El size 'small' deberia traducirse a t3.micro."
  }
}

run "tamano_medium_usa_instance_type_mayor" {
  command = plan

  module {
    source = "../modules/aws/compute"
  }

  variables {
    servers = [
      { name = "web-001", role = "web", size = "small" },
      { name = "app-001", role = "app", size = "medium" },
    ]
  }

  assert {
    condition     = aws_instance.this["app-001"].instance_type == "t3.small"
    error_message = "El size 'medium' deberia traducirse a t3.small."
  }
}

run "rechaza_lista_de_servidores_vacia" {
  command = plan

  module {
    source = "../modules/aws/compute"
  }

  variables {
    servers = []
  }

  expect_failures = [
    var.servers,
  ]
}
