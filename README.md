# terraform-iac-50-sucursales (ServiciosCloudIAC)

Infraestructura como Codigo (Terraform) para administrar **50 sucursales**
con un patron comun en **AWS y Google Cloud Platform**, desarrollada como
proyecto academico del curso Servicios Cloud (Universidad Tecnologica del
Peru).

> **Restriccion fundamental**: este proyecto **no cuenta con credenciales de
> AWS ni de GCP**. Nunca se ejecuta `terraform apply` contra la nube real ni
> se generan costos cloud. Toda la validacion se hace con `terraform
> validate`, `terraform test` + `mock_provider`, un laboratorio Docker local
> y un laboratorio de Terraform State/Drift con el provider `local`. Ver la
> seccion [Que esta validado y que no](#que-esta-validado-y-que-no).

## Indice

- [Arquitectura](#arquitectura)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Inicio rapido](#inicio-rapido)
- [Que esta validado y que no](#que-esta-validado-y-que-no)
- [Documentacion](#documentacion)
- [Licencia](#licencia)

## Arquitectura

Cada sucursal es una instancia de un patron comun (red + 2 servidores +
reglas de seguridad + monitoreo) definida como **datos**
(`config/branches/branches.yaml`), no como codigo repetido. Un unico modulo
orquestador (`terraform/modules/branch-stack`) ensambla los 8 modulos base
(`aws/{network,compute,security,monitoring}` y
`gcp/{network,compute,security,monitoring}`) por cada sucursal, segun su
`provider`.

Ver el detalle completo, diagramas y justificacion de herramientas en
[`docs/architecture/overview.md`](docs/architecture/overview.md).

## Estructura del repositorio

```text
.
├── terraform/
│   ├── modules/
│   │   ├── aws/{network,compute,security,monitoring}/
│   │   ├── gcp/{network,compute,security,monitoring}/
│   │   └── branch-stack/        # orquesta las 50 sucursales por entorno
│   ├── environments/{development,staging,production}/
│   └── tests/                   # terraform test + mock_provider
├── lab/
│   ├── local-terraform/         # ciclo de vida del Terraform State (local)
│   ├── drift/                   # demostracion de Infrastructure Drift (local)
│   ├── docker/                  # 2 sucursales simuladas con Docker Compose
│   └── monitoring/              # monitoreo ligero del laboratorio Docker
├── config/branches/branches.yaml  # fuente de verdad de las 50 sucursales
├── scripts/                     # generador de sucursales, validate/test/cleanup
├── .github/workflows/           # CI, seguridad y deteccion de drift
└── docs/
    ├── architecture/            # diseno, diagramas, justificacion de herramientas
    ├── academic/                # analisis de requisitos, matriz de trazabilidad, plan de pruebas
    ├── evidence/                # salidas reales de las ejecuciones (no fabricadas)
    └── user-guide/               # guia de ejecucion local paso a paso
```

## Inicio rapido

Requiere Git, Python 3.12+ con `pyyaml`, y el Terraform CLI portatil
incluido en `tools/` (ver [`docs/user-guide/README.md`](docs/user-guide/README.md)
para el detalle completo).

```powershell
# 1. Validaciones estaticas (fmt, validate x3 entornos, esquema de 50 sucursales)
./scripts/validate.ps1

# 2. Pruebas automatizadas con mock_provider (AWS + GCP, sin credenciales)
./scripts/test.ps1

# 3. Laboratorio de Terraform State (ciclo de vida completo, recursos locales)
cd lab/local-terraform; ./run_state_demo.ps1; cd ../..

# 4. Laboratorio de Infrastructure Drift (deteccion + reconciliacion)
cd lab/drift; ./run_drift_demo.ps1; cd ../..

# 5. Laboratorio Docker de 2 sucursales (requiere Docker Desktop)
cd lab/docker; ./start.ps1; ./test.ps1; ./stop.ps1; cd ../..
```

## Que esta validado y que no

| Mecanismo | Que SI demuestra | Que NO demuestra |
|---|---|---|
| `terraform validate` | La configuracion es sintacticamente correcta y consistente | Que AWS/GCP aceptarian esos recursos (cuotas, permisos, disponibilidad de la imagen/AMI) |
| `terraform test` + `mock_provider` | El wiring (variables, `for_each`, referencias entre modulos, validaciones) produce los recursos y atributos esperados | Comportamiento real de la API de AWS/GCP |
| Laboratorio Docker (`lab/docker`) | El patron "red aislada + 2 servidores" funciona y es verificable (HTTP, conectividad, aislamiento) | Que una VPC/EC2 o VPC Network/Compute Engine reales se comporten igual (Docker no es una VM cloud) |
| Laboratorio de State/Drift (`lab/local-terraform`, `lab/drift`) | El ciclo de vida del estado y la deteccion/reconciliacion de drift funcionan con Terraform real | El comportamiento especifico de un backend S3/GCS remoto con locking real |

Este proyecto distingue explicitamente, en cada README y en
[`docs/academic/plan-de-pruebas.md`](docs/academic/plan-de-pruebas.md), entre
**lo que se ejecuto realmente** y **lo que queda documentado como diseno
para un despliegue futuro con credenciales reales**.

## Documentacion

| Documento | Contenido |
|---|---|
| [`docs/architecture/overview.md`](docs/architecture/overview.md) | Arquitectura general, interfaz comun AWS/GCP, supuesto de distribucion |
| [`docs/architecture/aws-architecture.md`](docs/architecture/aws-architecture.md) | Arquitectura AWS en detalle |
| [`docs/architecture/gcp-architecture.md`](docs/architecture/gcp-architecture.md) | Arquitectura GCP en detalle |
| [`docs/architecture/terraform-state-strategy.md`](docs/architecture/terraform-state-strategy.md) | Estrategia de State (S3/GCS) + laboratorio local |
| [`docs/architecture/cicd-pipeline.md`](docs/architecture/cicd-pipeline.md) | Pipeline CI/CD, aprobaciones, habilitar despliegue real |
| [`docs/architecture/monitoring-strategy.md`](docs/architecture/monitoring-strategy.md) | Estrategia de monitoreo (empresarial + laboratorio) |
| [`docs/architecture/secrets-management.md`](docs/architecture/secrets-management.md) | Gestion de secretos |
| [`docs/academic/analisis-requisitos.md`](docs/academic/analisis-requisitos.md) | Requisitos funcionales/no funcionales, riesgos, supuestos |
| [`docs/academic/matriz-trazabilidad.md`](docs/academic/matriz-trazabilidad.md) | Matriz requisito -> solucion -> herramienta -> prueba -> evidencia |
| [`docs/academic/plan-de-pruebas.md`](docs/academic/plan-de-pruebas.md) | CP01-CP16 con resultados reales |
| [`docs/user-guide/README.md`](docs/user-guide/README.md) | Guia de ejecucion local paso a paso |

El informe academico formal (Word/PDF, formato IEEE) esta en
`docs/academic/` (ver seccion de entregables).

## Autores

Universidad Tecnologica del Peru — Curso Servicios Cloud.

Integrantes: Icochea Rodriguez, Thiago Paolo; Gonzales Aguilar, Carlos
Enrique Giussepe; Huamani Pereira, Eddyson Cesar; Torres Centeno, Emmanuel
Misael; Remuzgo Tovar, Huber Eduardo; Quispe Saavedra, Karen Meylin.

## Licencia

[MIT](LICENSE).
