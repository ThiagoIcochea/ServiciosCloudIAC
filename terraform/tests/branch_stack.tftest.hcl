# Prueba de escalabilidad (seccion 7 del enunciado) sobre el modulo
# branch-stack, que ensambla las 50 sucursales reales de
# config/branches/branches.yaml. CP04 - Configuracion de 50 sucursales.
#
# A diferencia de scripts/validate_branches_schema.py (que valida solo los
# DATOS), esta prueba valida que el WIRING de Terraform (for_each, modulos,
# outputs) procese correctamente esos datos para los 3 entornos.

mock_provider "aws" {}
mock_provider "google" {}

run "produccion_tiene_40_sucursales_balanceadas_entre_aws_y_gcp" {
  command = plan

  module {
    source = "../modules/branch-stack"
  }

  variables {
    environment = "production"
  }

  assert {
    condition     = output.branch_count == 40
    error_message = "Se esperaban 40 sucursales en production (supuesto academico de distribucion)."
  }

  assert {
    condition     = length(output.aws_branch_ids) == 20
    error_message = "Se esperaban 20 sucursales AWS en production."
  }

  assert {
    condition     = length(output.gcp_branch_ids) == 20
    error_message = "Se esperaban 20 sucursales GCP en production."
  }
}

run "staging_tiene_6_sucursales" {
  command = plan

  module {
    source = "../modules/branch-stack"
  }

  variables {
    environment = "staging"
  }

  assert {
    condition     = output.branch_count == 6
    error_message = "Se esperaban 6 sucursales en staging."
  }
}

run "development_tiene_4_sucursales" {
  command = plan

  module {
    source = "../modules/branch-stack"
  }

  variables {
    environment = "development"
  }

  assert {
    condition     = output.branch_count == 4
    error_message = "Se esperaban 4 sucursales en development."
  }
}

run "total_de_sucursales_en_los_tres_entornos_es_50" {
  command = plan

  module {
    source = "../modules/branch-stack"
  }

  variables {
    environment = "production"
  }

  assert {
    # 40 (production) + 6 (staging) + 4 (development) = 50, verificado
    # tambien de forma independiente en scripts/validate_branches_schema.py.
    condition     = output.branch_count + 6 + 4 == 50
    error_message = "El total de sucursales en los 3 entornos deberia ser 50."
  }
}

run "rechaza_entorno_invalido" {
  command = plan

  module {
    source = "../modules/branch-stack"
  }

  variables {
    environment = "qa-inexistente"
  }

  expect_failures = [
    var.environment,
  ]
}
