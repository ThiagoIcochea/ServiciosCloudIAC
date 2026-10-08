# Evidencia real: ejecuciones de GitHub Actions

Repositorio: https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions

| Run | Workflow | Trigger | Resultado | Duracion |
|---|---|---|---|---|
| [37781765625](https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37781765625) | Terraform CI | push (commit inicial) | FALLO — `terraform fmt` sin aplicar + 4 advertencias TFLint | 16s |
| [37781765505](https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37781765505) | Terraform Security | push (commit inicial) | EXITO | 44s |
| [37785036815](https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37785036815) | Terraform CI | push (fix fmt/TFLint) | EXITO (fmt, validate x3, esquema 50 sucursales, terraform test 27/27, TFLint) | 1m9s |
| [37785037002](https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37785037002) | Terraform Security | push (fix fmt/TFLint) | EXITO | 32s |
| [37785920920](https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37785920920) | Drift Check | workflow_dispatch (manual) | FALLO — `terraform apply` requeria init completo (`-backend=false` insuficiente) | 19s |
| [37786617247](https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37786617247) | Drift Check | workflow_dispatch (manual, tras fix) | EXITO — init, apply, modificacion manual y deteccion de drift (`Plan: 1 to add`) confirmados en el log | 13s |

## Lectura honesta de los 2 fallos iniciales

Ambos fallos fueron reales (no simulados) y se corrigieron con cambios de
codigo verificables en el historial de commits, no ocultados:

1. **Terraform CI (primer push)**: `terraform/tests/gcp_compute.tftest.hcl`
   no estaba formateado con `terraform fmt`, y TFLint detecto 3 variables
   declaradas sin uso (`gcp/monitoring.retention_days`, `gcp/network.tags`,
   `gcp/security.tags`) mas una interpolacion obsoleta
   (`target_tags = ["${var.name}"]`). Commit de correccion:
   `4864498` ("Corrige hallazgos reales del primer run de CI").
2. **Drift Check (primer trigger manual)**: el paso `terraform init
   -backend=false` no inicializa el backend `"local"` declarado
   explicitamente en `lab/drift/main.tf`, por lo que el `terraform apply`
   posterior fallaba con "Backend initialization required" — el mismo
   problema ya detectado y corregido localmente al ejecutar
   `lab/drift/run_drift_demo.ps1` por primera vez. Commit de correccion:
   `350bf87` ("Corrige drift-check.yml: terraform apply requiere init
   completo").

Esto demuestra, con evidencia real, el valor del pipeline: detecto
problemas genuinos antes de que llegaran a `main` sin supervision, y el
plan de pruebas (`docs/academic/plan-de-pruebas.md`, CP10) documenta ambos
fallos y sus correcciones en vez de omitirlos.
