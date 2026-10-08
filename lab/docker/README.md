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

## Requisito: Docker Desktop

Este laboratorio requiere Docker Desktop (o Docker Engine + Compose v2). En
el equipo donde se desarrollo este proyecto **Docker Desktop no estaba
instalado** y no se instalo automaticamente porque requiere habilitar
WSL2/Hyper-V (cambio critico de configuracion de Windows que el enunciado
pide no realizar sin autorizacion explicita). Por lo tanto:

- El laboratorio esta **completo y listo para ejecutarse** (`docker-compose.yml`,
  contenido HTML por servidor, scripts de inicio/prueba/limpieza).
- Su ejecucion real queda marcada como **CP16 bloqueada / pendiente** en el
  plan de pruebas (`docs/academic/plan-de-pruebas.md`) hasta que se instale
  Docker Desktop en el equipo de ejecucion, siguiendo la seccion 21 del
  enunciado ("no marques pruebas como aprobadas si no fueron ejecutadas").

## Ejecucion (una vez disponible Docker)

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
