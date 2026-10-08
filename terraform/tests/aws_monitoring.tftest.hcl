# Pruebas del modulo aws/monitoring usando mock_provider.
# CP02 - Validacion de modulos AWS. CP08 - Configuracion de monitoreo.

mock_provider "aws" {}

variables {
  name           = "suc-001"
  enabled        = true
  retention_days = 14
  instance_ids = {
    "web-001" = "i-mock0001"
    "app-001" = "i-mock0002"
  }
}

run "crea_log_group_cuando_monitoreo_habilitado" {
  command = plan

  module {
    source = "../modules/aws/monitoring"
  }

  assert {
    condition     = aws_cloudwatch_log_group.this[0].name == "/sucursales/suc-001"
    error_message = "El Log Group deberia nombrarse /sucursales/<id>."
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.cpu) == 2
    error_message = "Deberia crearse una alarma de CPU por servidor."
  }
}

run "no_crea_recursos_cuando_monitoreo_deshabilitado" {
  command = plan

  module {
    source = "../modules/aws/monitoring"
  }

  variables {
    enabled = false
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.this) == 0
    error_message = "No deberia crearse Log Group si enabled=false."
  }
}

run "rechaza_retention_days_no_soportado" {
  command = plan

  module {
    source = "../modules/aws/monitoring"
  }

  variables {
    retention_days = 13
  }

  expect_failures = [
    var.retention_days,
  ]
}
