# Analisis de requisitos

## Contexto empresarial

Una empresa con 50 sucursales necesita administrar su infraestructura
tecnologica mediante un patron comun de aprovisionamiento, usando AWS y
Google Cloud Platform, con un proceso de revision/aprobacion comun a ambos
proveedores y sin almacenar secretos en el repositorio.

## Problematica

Aprovisionar y mantener manualmente la infraestructura de 50 sucursales (o
copiando configuracion sucursal por sucursal) es propenso a errores,
dificil de auditar, dificil de escalar y no detecta cuando alguien modifica
manualmente un recurso en produccion (Infrastructure Drift).

## Objetivo general

Disenar, implementar y validar localmente una solucion de Infraestructura
como Codigo (IaC) con Terraform que aprovisione el patron comun de 50
sucursales en AWS y GCP, de forma reutilizable, segura, probada y
documentada, sin requerir credenciales cloud para su demostracion.

## Objetivos especificos

1. Disenar una arquitectura multi-cloud con interfaz de configuracion comun
   entre AWS y GCP.
2. Implementar modulos Terraform reutilizables (red, computo, seguridad,
   monitoreo) para ambos proveedores.
3. Demostrar que la solucion escala a 50 sucursales sin duplicar codigo.
4. Implementar una estrategia de pruebas sin credenciales cloud
   (`terraform test` + `mock_provider`, pruebas de esquema en Python,
   laboratorio Docker).
5. Disenar la gestion del Terraform State (estrategia empresarial +
   laboratorio local funcional).
6. Implementar un pipeline CI/CD comun a ambos proveedores con controles de
   seguridad (TFLint, Checkov, gitleaks) y un procedimiento de aprobacion.
7. Demostrar, con un recurso local real, el ciclo completo de deteccion y
   reconciliacion de Infrastructure Drift.
8. Documentar el proyecto en formato academico IEEE y publicarlo en un
   repositorio GitHub.

## Requisitos funcionales (RF)

| ID | Requisito |
|----|-----------|
| RF-01 | Cada sucursal debe tener una red independiente/segmentada |
| RF-02 | Cada sucursal debe tener dos servidores |
| RF-03 | Cada sucursal debe tener reglas de seguridad |
| RF-04 | Cada sucursal debe tener monitoreo |
| RF-05 | La solucion debe soportar AWS y GCP |
| RF-06 | Debe ser posible agregar una sucursal nueva sin duplicar modulos |
| RF-07 | Debe ser posible modificar una sucursal sin afectar a las demas |
| RF-08 | Los entornos deben estar separados (development/staging/production) |
| RF-09 | El estado de Terraform debe estar aislado por entorno |

## Requisitos no funcionales (RNF)

| ID | Requisito |
|----|-----------|
| RNF-01 | Extensibilidad: agregar una sucursal es un cambio de datos, no de codigo |
| RNF-02 | Reproducibilidad: cualquier persona con el repo puede ejecutar las validaciones locales sin credenciales |
| RNF-03 | Seguridad: ningun secreto en el repositorio; principio de minimo privilegio documentado |
| RNF-04 | Eficiencia de recursos: el laboratorio local debe funcionar en un equipo de 8 GB RAM sin GPU |
| RNF-05 | Mantenibilidad: modulos documentados (README, variables y outputs descritos) |

## Restricciones tecnicas

- Sin credenciales de AWS ni GCP (no se ejecuta `terraform apply` real).
- Equipo de desarrollo: Windows 11, 8 GB RAM, sin GPU dedicada.
- Docker Desktop no operativo en el equipo de desarrollo local (requiere
  reiniciar Windows para activar WSL2, reinicio que se decidio no
  realizar): el laboratorio Docker se ejecuta realmente en GitHub Actions
  (runner `ubuntu-latest`, con Docker preinstalado) en vez de en el equipo
  local (ver `lab/docker/README.md`).

## Riesgos

| Riesgo | Mitigacion |
|---|---|
| Confundir una validacion con mocks con un despliegue real | Documentacion explicita en cada README y en el plan de pruebas sobre que SI y que NO valida cada mecanismo |
| Drift no detectado en produccion | Workflow programado `drift-check.yml` (demostrado localmente) |
| Secretos filtrados accidentalmente | `.gitignore` + `gitleaks` + verificacion adicional en CI |
| Limitaciones de recursos del equipo de desarrollo | Laboratorio Docker reducido a 2 sucursales / 4 contenedores; monitoreo ligero en vez de Prometheus/Grafana |

## Supuestos

- La distribucion de sucursales entre AWS y GCP (25/25) es un supuesto
  academico para esta demostracion (seccion 5 de `docs/architecture/overview.md`).
- Los valores de `ami_id`/`image` de los modulos de computo son ejemplos
  academicos, no validados contra una cuenta real de AWS/GCP.
- `project_id` de GCP (`academic-demo-project`) es un identificador de
  ejemplo, no un proyecto GCP real.

## Criterios de aceptacion

Ver `docs/academic/plan-de-pruebas.md` (CP01-CP16): el proyecto se considera
conforme cuando todas las pruebas (CP01-CP16) pasan con evidencia real, sin
afirmarse como aprobadas pruebas que no se ejecutaron. Las pruebas que
dependen de Docker (laboratorio de 2 sucursales, monitoreo local) se
ejecutaron realmente en GitHub Actions en vez de en el equipo de desarrollo
local (ver `docs/academic/plan-de-pruebas.md`, seccion "Laboratorio Docker —
ejecucion real").
