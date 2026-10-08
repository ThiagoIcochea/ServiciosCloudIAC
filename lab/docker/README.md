# Laboratorio Docker - 2 sucursales representativas

Demuestra, a escala de laboratorio, el patron de infraestructura que
Terraform define para las 50 sucursales: **una red aislada por sucursal y
dos servidores dentro de cada una**. Docker aqui es una ayuda visual y de
pruebas de conectividad/aislamiento de red; **no reemplaza** a las maquinas
virtuales cloud reales (EC2 / Compute Engine) que define el codigo Terraform.

```
sucursal-01-net          sucursal-02-net
  suc01-web01 (:8081)      suc02-web01 (:8091)
  suc01-app01 (:8082)      suc02-app01 (:8092)
```

## Ejecucion real: GitHub Actions (CI)

El equipo de desarrollo local de este proyecto **no tiene Docker Desktop
operativo** (instalado, pero sin poder iniciar: requiere activar WSL2, lo
que a su vez requiere reiniciar Windows, reinicio que se decidio no
realizar). En vez de simular resultados, el laboratorio se ejecuta
**realmente** en `.github/workflows/docker-lab.yml`, sobre un runner
`ubuntu-latest` de GitHub Actions (estos runners traen Docker Engine +
Docker Compose preinstalados de fabrica).

Resultado real (run
[37832592874](https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37832592874),
36s, exitoso): los 4 contenedores llegaron a `healthy`, las 4 pruebas HTTP
devolvieron `200`, la conectividad interna se confirmo en ambas sucursales,
y el aislamiento de red se confirmo en ambas direcciones. Ver evidencia
completa en `docs/evidence/docker-lab/` y el detalle en
`docs/academic/plan-de-pruebas.md` (seccion "Laboratorio Docker — ejecucion
real").

## Ejecucion local (si tienes Docker Desktop disponible)

```powershell
cd lab/docker
./start.ps1   # inicia los 4 contenedores
./test.ps1    # pruebas HTTP, conectividad interna y aislamiento entre redes
./stop.ps1    # detiene y limpia
```

## Que valida `test.ps1`

1. **HTTP**: cada uno de los 4 servidores responde 200 OK en su puerto
   publicado.
2. **Conectividad interna**: `web01` puede alcanzar `app01` dentro de la
   misma sucursal (misma red Docker).
3. **Aislamiento de red**: `sucursal-01-net` y `sucursal-02-net` NO estan
   conectadas entre si, igual que las VPC/VPC Network de cada sucursal en
   Terraform son independientes.

## Consumo de recursos

Solo 4 contenedores `nginx:alpine` (~10-15 MB cada uno). No se inician 100
contenedores ni se intenta representar las 50 sucursales en Docker: esa
escala la demuestra Terraform (`terraform/modules`, `config/branches`),
mientras Docker demuestra el patron en una maqueta reducida y verificable.
