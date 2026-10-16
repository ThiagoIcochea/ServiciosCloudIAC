# Reparticion de tareas

El proyecto se dividio en cinco frentes de trabajo, uno por integrante, de
modo que cada persona fuera responsable de una parte completa de la
solucion (diseno, codigo, pruebas y documentacion de esa parte). La
integracion final, la revision cruzada de Pull Requests y la redaccion del
informe se hicieron en conjunto.

## Resumen por integrante

| Integrante | Rol | Responsabilidad principal |
|---|---|---|
| Icochea Rodriguez, Thiago Paolo | Coordinador y arquitecto de la solucion | Arquitectura multi-cloud, modulo orquestador `branch-stack`, datos de las 50 sucursales, entornos y repositorio GitHub |
| Gonzales Aguilar, Carlos Enrique Giussepe | Responsable de infraestructura AWS | Modulos `aws/network`, `aws/compute`, `aws/security`, `aws/monitoring` y sus pruebas |
| Huamani Pereira, Eddyson Cesar | Responsable de infraestructura GCP | Modulos `gcp/network`, `gcp/compute`, `gcp/security`, `gcp/monitoring` y sus pruebas |
| Remuzgo Tovar, Huber Eduardo | Responsable de CI/CD y seguridad | Workflows de GitHub Actions, TFLint, Checkov, gitleaks, gestion de secretos y laboratorio Docker en CI |
| Quispe Saavedra, Karen Meylin | Responsable de State, Drift y pruebas | Laboratorios de Terraform State e Infrastructure Drift, monitoreo local, plan de pruebas y evidencias |

## Detalle de tareas

### Icochea Rodriguez, Thiago Paolo — Coordinador y arquitecto

- Diseno de la arquitectura general y de la interfaz comun AWS/GCP
  (`docs/architecture/overview.md`, Figuras 1 y 4).
- Modulo orquestador `terraform/modules/branch-stack` (filtrado por
  entorno y proveedor con `for_each`).
- Fuente de verdad de las sucursales: `config/branches/branches.yaml` y su
  generador `scripts/generate_branches.py` (distribucion 25 AWS / 25 GCP).
- Entornos `terraform/environments/{development,staging,production}`.
- Script de validacion de escalabilidad `scripts/validate_branches_schema.py`
  y pruebas `branch_stack.tftest.hcl`.
- Creacion y administracion del repositorio GitHub, revision de Pull
  Requests e integracion final.
- Casos de prueba a cargo: CP01, CP04, CP15.

### Gonzales Aguilar, Carlos Enrique Giussepe — Infraestructura AWS

- Modulo `aws/network`: VPC, subnet, Internet Gateway y tabla de rutas por
  sucursal.
- Modulo `aws/compute`: dos instancias EC2 (web y app) por sucursal.
- Modulo `aws/security`: Security Group por sucursal con sus reglas.
- Modulo `aws/monitoring`: Log Group de CloudWatch y alarmas de CPU.
- Pruebas `aws_*.tftest.hcl` con `mock_provider "aws"`, incluida la
  correccion del error real de indexacion sobre un `set` en
  `aws_route_table`.
- Documentacion `docs/architecture/aws-architecture.md` y Figura 2.
- Casos de prueba a cargo: CP02, CP05 (AWS), CP06 (AWS).

### Huamani Pereira, Eddyson Cesar — Infraestructura GCP

- Modulo `gcp/network`: VPC en modo personalizado, subnetwork, Cloud Router
  y Cloud NAT.
- Modulo `gcp/compute`: dos instancias de Compute Engine por sucursal.
- Modulo `gcp/security`: una regla `google_compute_firewall` por cada regla
  declarada.
- Modulo `gcp/monitoring`: politica de alerta de CPU en Cloud Monitoring.
- Pruebas `gcp_*.tftest.hcl` con `mock_provider "google"` y correccion de
  las advertencias de TFLint detectadas en el primer run de CI.
- Documentacion `docs/architecture/gcp-architecture.md` (diferencias
  tecnicas con AWS) y Figura 3.
- Casos de prueba a cargo: CP03, CP05 (GCP), CP06 (GCP), CP09.

### Remuzgo Tovar, Huber Eduardo — CI/CD y seguridad

- Pipeline `terraform-ci.yml` (fmt, validate x3 entornos, esquema,
  `terraform test`, TFLint) y configuracion `terraform/.tflint.hcl`.
- Workflow `terraform-security.yml` (Checkov, gitleaks y verificacion
  adicional de secretos) y `.gitignore`.
- Workflow `docker-lab.yml` y laboratorio `lab/docker` (2 sucursales, 4
  contenedores, aislamiento de red) ejecutado en GitHub Actions.
- Procedimiento de aprobacion por Pull Request
  (`.github/pull_request_template.md`).
- Documentacion `docs/architecture/cicd-pipeline.md` y
  `docs/architecture/secrets-management.md`, Figuras 5 y 8.
- Casos de prueba a cargo: CP07, CP10, CP11, CP16 (Docker).

### Quispe Saavedra, Karen Meylin — State, Drift y pruebas

- Laboratorio `lab/local-terraform` (ciclo de vida completo del Terraform
  State) y estrategia de backends S3/GCS
  (`docs/architecture/terraform-state-strategy.md`, Figura 6).
- Laboratorio `lab/drift` y workflow `drift-check.yml` (deteccion y
  reconciliacion de Infrastructure Drift, Figura 7).
- Monitoreo local `lab/monitoring/healthcheck_monitor.py` y
  `docs/architecture/monitoring-strategy.md`.
- Plan de pruebas CP01-CP16 (`docs/academic/plan-de-pruebas.md`), matriz de
  trazabilidad y recopilacion de evidencias en `docs/evidence/`.
- Casos de prueba a cargo: CP08, CP12, CP13, CP14, CP16 (Terraform).

## Tareas compartidas

| Tarea | Participantes |
|---|---|
| Analisis de requisitos (RF, RNF, riesgos, supuestos) | Todos |
| Revision cruzada de Pull Requests | Todos (al menos un revisor distinto al autor) |
| Redaccion y revision del informe academico | Todos, consolidado por Thiago Icochea |
| Preparacion de la sustentacion | Todos (cada integrante expone su frente) |
