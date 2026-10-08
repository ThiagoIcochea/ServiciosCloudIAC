# Monitoreo local ligero

Alternativa ligera a Prometheus + Grafana para el laboratorio Docker de 2
sucursales (ver justificacion completa en el docstring de
`healthcheck_monitor.py` y en `docs/architecture/monitoring-strategy.md`).

```powershell
cd lab/docker
./start.ps1
cd ../monitoring
python healthcheck_monitor.py --iterations 5 --interval 10
```

Genera un archivo `.jsonl` en `docs/evidence/monitoring/` con, para cada
iteracion: estado HTTP de los 4 servidores, estado de `healthcheck` de
Docker y uso de CPU/memoria por contenedor (`docker stats`).

## Dependencia de Docker

Al igual que `lab/docker`, la ejecucion real de este script depende de
Docker Desktop, no disponible en el equipo de desarrollo de este proyecto
(ver `lab/docker/README.md`). El script esta implementado y probado
sintacticamente; su ejecucion queda marcada como pendiente/bloqueada hasta
contar con Docker, igual que CP16.
