# Plan de pruebas

Formato por caso: Identificador, Objetivo, Precondiciones, Procedimiento,
Resultado esperado, Resultado obtenido, Estado, Evidencia.

> **Estado** usa 4 valores: `APROBADA` (se ejecuto y paso), `FALLIDA` (se
> ejecuto, fallo, se corrigio y se re-ejecuto — ver columna Resultado
> obtenido para el historial), `BLOQUEADA` (no se pudo ejecutar por una
> dependencia externa, documentada) o `PENDIENTE` (no ejecutada aun). Nunca
> se marca `APROBADA` sin ejecucion real.

## CP01 — Validacion sintactica de Terraform

- **Objetivo**: confirmar que todo el codigo Terraform del proyecto es
  sintacticamente valido y esta correctamente formateado.
- **Precondiciones**: Terraform CLI 1.9.8 disponible (`tools/terraform.exe`).
- **Procedimiento**: `terraform fmt -check -recursive terraform/`;
  `terraform init -backend=false` + `terraform validate` en
  `terraform/environments/{development,staging,production}`.
- **Resultado esperado**: `fmt` sin cambios pendientes; `validate` reporta
  "Success! The configuration is valid." en los 3 entornos.
- **Resultado obtenido**: `fmt -recursive` reformateo 4 archivos en la
  primera corrida (alineacion de `=`); tras `fmt`, `validate` fue exitoso en
  `production` (40 sucursales), `staging` (6) y `development` (4).
- **Estado**: APROBADA.
- **Evidencia**: `docs/evidence/terraform-validate/`.

## CP02 — Validacion de modulos AWS

- **Objetivo**: verificar que los 4 modulos AWS (`network`, `compute`,
  `security`, `monitoring`) generan la configuracion esperada.
- **Precondiciones**: `mock_provider "aws" {}` disponible (Terraform >= 1.7).
- **Procedimiento**: `terraform test` sobre `aws_network.tftest.hcl`,
  `aws_compute.tftest.hcl`, `aws_security.tftest.hcl`,
  `aws_monitoring.tftest.hcl`.
- **Resultado esperado**: todos los `run` en `pass`.
- **Resultado obtenido**: 1 fallo real detectado y corregido —
  `aws_route_table.this.route[0]` no es valido porque `route` es un `set`
  (sin indice); se corrigio a `anytrue([for r in ... : r.cidr_block == ...])`
  y se re-ejecuto. Resto de los `run` en `pass` desde la primera corrida.
- **Estado**: APROBADA (tras correccion).
- **Evidencia**: `docs/evidence/terraform-test/`.

## CP03 — Validacion de modulos GCP

- **Objetivo**: verificar que los 4 modulos GCP generan la configuracion
  esperada.
- **Precondiciones**: `mock_provider "google" {}`.
- **Procedimiento**: `terraform test` sobre `gcp_network.tftest.hcl`,
  `gcp_compute.tftest.hcl`, `gcp_security.tftest.hcl`,
  `gcp_monitoring.tftest.hcl`.
- **Resultado esperado**: todos los `run` en `pass`.
- **Resultado obtenido**: ver `docs/evidence/terraform-test/`.
- **Estado**: APROBADA.
- **Evidencia**: `docs/evidence/terraform-test/`.

## CP04 — Configuracion de 50 sucursales

- **Objetivo**: confirmar que existen exactamente 50 sucursales definidas y
  que el modulo `branch-stack` las procesa correctamente por entorno.
- **Procedimiento**: `python scripts/validate_branches_schema.py`;
  `terraform test` sobre `branch_stack.tftest.hcl`.
- **Resultado esperado**: 50 sucursales totales (40 production + 6 staging +
  4 development), 25 AWS / 25 GCP.
- **Resultado obtenido**: confirmado por ambos mecanismos (Python y
  Terraform test), de forma independiente.
- **Estado**: APROBADA.
- **Evidencia**: salida de ambos comandos en `docs/evidence/`.

## CP05 — Dos servidores por sucursal

- **Procedimiento**: aserciones `length(aws_instance.this) == 2` /
  `length(google_compute_instance.this) == 2` en `aws_compute.tftest.hcl` /
  `gcp_compute.tftest.hcl`; verificacion independiente en
  `validate_branches_schema.py` sobre las 50 entradas de `branches.yaml`.
- **Estado**: APROBADA.

## CP06 — Redes independientes

- **Procedimiento**: aserciones sobre CIDR unico por sucursal en
  `aws_network.tftest.hcl` / `gcp_network.tftest.hcl`; verificacion de CIDR
  valido y no colisionante por diseno (`scripts/generate_branches.py` deriva
  el CIDR del indice de la sucursal) en `validate_branches_schema.py`.
- **Estado**: APROBADA.

## CP07 — Reglas de seguridad

- **Procedimiento**: aserciones de numero y contenido de reglas en
  `aws_security.tftest.hcl` / `gcp_security.tftest.hcl`.
- **Estado**: APROBADA.

## CP08 — Configuracion de monitoreo

- **Procedimiento**: aserciones sobre `aws_cloudwatch_log_group` /
  `google_monitoring_alert_policy` en `aws_monitoring.tftest.hcl` /
  `gcp_monitoring.tftest.hcl`.
- **Estado**: APROBADA.

## CP09 — Pruebas con mock_provider

- **Objetivo**: confirmar que la estrategia de pruebas sin credenciales
  (`mock_provider`) funciona end-to-end.
- **Resultado obtenido**: las 9 suites de `terraform/tests/*.tftest.hcl` se
  ejecutaron con `mock_provider "aws" {}` y `mock_provider "google" {}`, sin
  ninguna llamada de red a AWS/GCP.
- **Estado**: APROBADA.

## CP10 — Ejecucion de GitHub Actions

- **Objetivo**: confirmar que `terraform-ci.yml`, `terraform-security.yml` y
  `drift-check.yml` se ejecutan correctamente en GitHub Actions tras el
  push.
- **Procedimiento**: revisar la pestana "Actions" del repositorio publicado
  tras el primer push.
- **Resultado obtenido**: tras el primer push, `Terraform CI` fallo (hallazgos
  reales: `terraform fmt` sin aplicar en un archivo de prueba y 4
  advertencias de TFLint en los modulos GCP — variables sin uso y una
  interpolacion obsoleta). Se corrigieron los 3 modulos GCP afectados y se
  volvio a hacer push; el nuevo run de `Terraform CI` paso exitosamente
  (fmt, validate x3 entornos, esquema de 50 sucursales, terraform test 27/27,
  TFLint). `Terraform Security` paso en ambos pushes. `drift-check.yml` se
  disparo manualmente (`workflow_dispatch`) y fallo en su primera ejecucion
  por el mismo problema de inicializacion de backend detectado localmente en
  CP13 (`-backend=false` no inicializa el backend "local" declarado
  explicitamente); corregido y re-ejecutado, el run confirma init, apply,
  modificacion manual y deteccion de drift (`Plan: 1 to add`) reales en
  GitHub Actions.
- **Estado**: APROBADA.
- **Evidencia**: runs reales en
  https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions
  (`Terraform CI` run 37785036815, `Terraform Security` runs 37781765505 y
  37785037002, `Drift Check` run 37786617247).

## CP11 — Verificacion de secretos

- **Procedimiento**: `git ls-files | grep -E '\.tfstate|\.pem$|\.key$'`
  (debe no retornar nada); revision manual de `.gitignore`; `gitleaks`
  ejecutado en CI.
- **Resultado obtenido**: 0 coincidencias encontradas localmente.
- **Estado**: APROBADA (verificacion local); se reconfirmara con el run de
  `terraform-security.yml` en GitHub Actions.

## CP12 — Consulta de Terraform State

- **Procedimiento**: `lab/local-terraform/run_state_demo.ps1`
  (`terraform state list`, `terraform show`).
- **Estado**: APROBADA.
- **Evidencia**: `docs/evidence/state/`.

## CP13 — Deteccion de Infrastructure Drift

- **Procedimiento**: `lab/drift/run_drift_demo.ps1` — modificacion manual
  del archivo gestionado y `terraform plan` posterior.
- **Resultado esperado**: `terraform plan` reporta un cambio pendiente
  (el contenido declarado difiere del real).
- **Estado**: APROBADA.
- **Evidencia**: `docs/evidence/drift/`.

## CP14 — Reconciliacion de Drift

- **Procedimiento**: `terraform apply` posterior al `plan` del CP13, que
  revierte el archivo al contenido declarado en el codigo.
- **Estado**: APROBADA.
- **Evidencia**: `docs/evidence/drift/` (mismo log que CP13, pasos 8-9).

## CP15 — Incorporacion de una nueva sucursal

- **Objetivo**: demostrar que agregar una sucursal es un cambio de datos.
- **Procedimiento**: agregar una entrada de prueba a
  `scripts/generate_branches.py` (`TOTAL_SUCURSALES = 51`), regenerar
  `branches.yaml`, ejecutar `validate_branches_schema.py` y
  `terraform test` sobre `branch_stack.tftest.hcl` (ajustando el valor
  esperado temporalmente), confirmar que ningun archivo `.tf` cambio, y
  revertir.
- **Estado**: APROBADA.
- **Evidencia**: `docs/evidence/scalability/`.

## Laboratorio Docker — ejecucion real (GitHub Actions)

- **Objetivo**: ejecutar realmente el laboratorio de 2 sucursales (4
  contenedores, pruebas HTTP, conectividad interna, aislamiento de red),
  dado que el equipo de desarrollo local no tiene Docker Desktop instalado.
- **Procedimiento**: se creo `.github/workflows/docker-lab.yml`, que corre
  en un runner `ubuntu-latest` de GitHub Actions (estos runners traen
  Docker Engine + Docker Compose preinstalados de fabrica). El workflow
  levanta los 4 contenedores, espera los healthchecks, prueba HTTP en los 4
  puertos publicados, prueba conectividad interna (`web` <-> `app` dentro
  de cada sucursal) y prueba aislamiento de red entre `sucursal-01-net` y
  `sucursal-02-net`, y finalmente limpia con `docker compose down -v`.
- **Resultado obtenido** (run real, 36s, exitoso):
  - Los 4 contenedores llegaron a estado `healthy`.
  - Las 4 pruebas HTTP devolvieron `status=200`.
  - Conectividad interna confirmada en ambas sucursales.
  - Aislamiento de red confirmado en ambas direcciones
    (`suc01-web01 -> suc02-web01` y `suc02-web01 -> suc01-web01`, ambas con
    `exit=1`, es decir, sin acceso).
  - `docker compose down -v` se ejecuto sin errores.
- **Estado**: APROBADA.
- **Evidencia**: `docs/evidence/docker-lab/docker-lab-github-actions-run37832592874.log`
  (log completo real) y run
  https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37832592874.
- **Nota honesta**: esta ejecucion ocurrio en un runner Linux de GitHub
  Actions, no en el equipo Windows de desarrollo (que sigue sin Docker
  Desktop operativo porque WSL2 requiere un reinicio de Windows que el
  usuario pidio no realizar). El codigo del laboratorio (`docker-compose.yml`,
  scripts) es identico en ambos casos; lo unico que cambia es donde corrio.

## CP16 — Limpieza del laboratorio

- **Objetivo**: confirmar que `scripts/cleanup.ps1` / `lab/drift/cleanup.ps1`
  dejan el entorno sin artefactos residuales (estado, contenedores).
- **Procedimiento**: ejecutar los laboratorios, luego los scripts de
  limpieza, luego verificar ausencia de `.terraform/`, `terraform.tfstate*`
  y contenedores Docker activos.
- **Resultado obtenido**: limpieza de los laboratorios Terraform
  (`lab/drift`, `lab/local-terraform`) verificada localmente; limpieza del
  laboratorio Docker (`docker compose down -v`) verificada en el run de
  GitHub Actions descrito arriba (paso final, `if: always()`, sin errores).
- **Estado**: APROBADA.
- **Nota**: `lab/docker/stop.ps1` (el script equivalente para ejecucion
  local con Docker Desktop) sigue sin probarse en el equipo de desarrollo
  local por la misma razon (Docker Desktop instalado pero no operativo sin
  reiniciar Windows); la limpieza en si misma (`docker compose down -v`) ya
  quedo demostrada en CI.
