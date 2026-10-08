# Laboratorio de Infrastructure Drift

Demuestra, con recursos 100% locales (provider `hashicorp/local`, sin
credenciales cloud), el ciclo completo de deteccion y reconciliacion de
Infrastructure Drift exigido en la FASE VI del enunciado.

## Por que un recurso local y no uno de AWS/GCP

Este proyecto no cuenta con credenciales de AWS ni de GCP (restriccion
fundamental del enunciado). El **mecanismo** de deteccion de drift de
Terraform (`terraform plan`, `terraform plan -refresh-only`,
`terraform state show`) es identico sin importar el proveedor: compara el
estado guardado contra el estado real del recurso. Usar `local_file` permite
demostrar ese mecanismo end-to-end de forma honesta y reproducible, sin
simular una conexion a AWS/GCP que no existe.

## Diferencias entre Drift local y Drift en un proveedor cloud real

| Aspecto | Este laboratorio (local) | AWS / GCP real |
|---|---|---|
| Deteccion del cambio | Terraform lee el archivo en disco | Terraform llama a la API del proveedor (`DescribeInstances`, `compute.instances.get`, etc.) |
| Alcance del drift | Un solo atributo (contenido del archivo) | Puede afectar decenas de atributos computados, IDs, politicas IAM, etc. |
| Costo de refrescar el estado | Nulo | Puede generar llamadas a la API facturables o sujetas a rate limit |
| Quien puede causar el drift | Cualquier proceso con acceso al filesystem | Consola web, CLI, otro pipeline, un script de otro equipo |
| Riesgo de reconciliar sin analizar | Bajo (un archivo de texto) | Alto (podria destruir/recrear un recurso en produccion con perdida de datos) |

## Ejecucion

```powershell
cd lab/drift
./run_drift_demo.ps1
```

El script ejecuta, en orden, los 10 pasos descritos en la seccion 15 del
enunciado (init, apply, estado inicial, modificacion manual, plan, plan
-refresh-only, decision de reconciliar, apply, verificacion final) y guarda
la salida real de cada paso en `docs/evidence/drift/`.

Para limpiar el laboratorio:

```powershell
./cleanup.ps1
```

## Importante

`terraform apply -refresh-only` **no** modifica la infraestructura: solo
actualiza el archivo de estado para que refleje la realidad observada. Para
revertir el drift (volver el recurso a lo declarado en el codigo) se necesita
un `terraform apply` normal, que es el paso 8 de este laboratorio. Nunca se
asume que "actualizar el estado" equivale a "corregir la infraestructura".
